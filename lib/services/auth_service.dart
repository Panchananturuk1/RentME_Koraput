import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:crypto/crypto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/user_model.dart';
import '../core/constants/app_constants.dart';
import 'supabase_service.dart';
import 'whatsapp_otp_service.dart';
import 'twilio_sms_service.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  UserModel? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _authToken;
  
  // WhatsApp OTP service
  final WhatsAppOTPService _whatsappOTPService = WhatsAppOTPService();
  
  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get authToken => _authToken;
  
  // Hive box for local storage
  Box? _userBox;
  Box? _authBox;

  // Initialize the service
  Future<void> initialize() async {
    try {
      _userBox = await Hive.openBox('user_data');
      _authBox = await Hive.openBox('auth_data');
      
      // Initialize Twilio SMS service
      TwilioSmsService.initialize();
      
      // Check if user is already logged in
      await _loadStoredUser();
    } catch (e) {
      debugPrint('Error initializing AuthService: $e');
    }
  }

  // Load stored user data
  Future<void> _loadStoredUser() async {
    try {
      final userData = _authBox?.get('current_user');
      final token = _authBox?.get('auth_token');
      
      if (userData != null && token != null) {
        _currentUser = UserModel.fromJson(Map<String, dynamic>.from(userData));
        _authToken = token;
        _isAuthenticated = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading stored user: $e');
    }
  }

  // Save user data to local storage
  Future<void> _saveUserData() async {
    try {
      if (_currentUser != null && _authToken != null) {
        await _authBox?.put('current_user', _currentUser!.toJson());
        await _authBox?.put('auth_token', _authToken);
      }
    } catch (e) {
      debugPrint('Error saving user data: $e');
    }
  }

  // Ensure Hive boxes are initialized before use
  Future<void> _ensureInitialized() async {
    try {
      if (!Hive.isBoxOpen('user_data')) {
        _userBox = await Hive.openBox('user_data');
      } else {
        _userBox ??= Hive.box('user_data');
      }
      if (!Hive.isBoxOpen('auth_data')) {
        _authBox = await Hive.openBox('auth_data');
      } else {
        _authBox ??= Hive.box('auth_data');
      }
    } catch (e) {
      debugPrint('Error ensuring AuthService initialized: $e');
    }
  }

  // Send OTP to email (using Supabase Auth)
  Future<Map<String, dynamic>> sendOTP(String email, String userType) async {
    _setLoading(true);
    
    try {
      await SupabaseService.signInWithOtp(email: email);
      
      final response = {
        'success': true,
        'message': 'OTP sent to your email successfully',
        'email': email,
        'expires_in': 300, // 5 minutes
      };
      
      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to send OTP. Please check your email and try again.',
        'error': e.toString(),
      };
    } finally {
      _setLoading(false);
    }
  }

  // Login with WhatsApp using OTPless
  Future<Map<String, dynamic>> loginWithWhatsApp({
    required String userType,
  }) async {
    _setLoading(true);
    
    try {
      // Initialize WhatsApp OTP service if not already done
      await _whatsappOTPService.initialize();
      
      final result = await _whatsappOTPService.openLoginPage();
      
      if (!result['success']) {
        return result;
      }
      
      // Handle the authentication result
      final authData = result['data'];
      if (authData != null && authData['data'] != null) {
        return await _handleWhatsAppAuthResult(
          authData: authData['data'],
          userType: userType,
        );
      }
      
      return {
        'success': true,
        'message': 'WhatsApp authentication initiated',
        'data': result['data'],
      };
    } catch (e) {
      debugPrint('Error in WhatsApp login: $e');
      return {
        'success': false,
        'message': 'WhatsApp login failed: $e',
      };
    } finally {
      _setLoading(false);
    }
  }

  // Handle WhatsApp authentication result from OTPless
  Future<Map<String, dynamic>> _handleWhatsAppAuthResult({
    required Map<String, dynamic> authData,
    required String userType,
  }) async {
    try {
      // Extract user data from OTPless response
      String? phoneNumber;
      String? name;
      String? email;
      String? token;
      
      // Parse the authentication data based on OTPless response format
      if (authData['mobile'] != null) {
        phoneNumber = authData['mobile']['number'];
        name = authData['mobile']['name'];
      }
      
      if (authData['token'] != null) {
        token = authData['token'];
      }
      
      if (phoneNumber == null) {
        return {
          'success': false,
          'message': 'Phone number not found in authentication data',
        };
      }
      
      final userData = {
        'phone': phoneNumber,
        'name': name ?? 'WhatsApp User',
        'email': email ?? '$phoneNumber@whatsapp.user',
        'user_type': userType,
        'auth_method': 'whatsapp',
        'created_at': DateTime.now().toIso8601String(),
      };
      
      // Check if user exists in our database
      final existingUserData = await SupabaseService.select(
        table: 'users',
        columns: '*',
        filter: 'eq:phone:${phoneNumber ?? ''}',
      );
      
      UserModel user;
      bool isNewUser = false;
      final existingUser = existingUserData.where((u) => u['phone'] == phoneNumber).firstOrNull;
      
      if (existingUser != null) {
        user = UserModel.fromJson(existingUser);
      } else {
        // Create new user profile
        final uuid = const Uuid();
        final userId = uuid.v4();
        user = UserModel(
          id: userId,
          phone: phoneNumber,
          userType: userType,
          name: userData['name'] ?? '',
          email: userData['email'] ?? '',
          profileImage: '',
          isVerified: true, // WhatsApp verified
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        // Save new user to Supabase
        await SupabaseService.insert(
          table: 'users',
          data: user.toSupabaseUsersJson(),
        );
        isNewUser = true;
      }
      
      _authToken = token ?? phoneNumber;
      _currentUser = user;
      _isAuthenticated = true;
      
      // Save to local storage
      await _saveUserData();
      
      notifyListeners();
      
      return {
        'success': true,
        'message': isNewUser ? 'Account created successfully' : 'Login successful',
        'user': user.toJson(),
        'token': _authToken,
        'is_new_user': isNewUser,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'WhatsApp authentication failed: $e',
        'error': e.toString(),
      };
    }
  }

  // Check if WhatsApp is available
  Future<bool> isWhatsAppAvailable() async {
    try {
      return await _whatsappOTPService.isWhatsAppAvailable();
    } catch (e) {
      debugPrint('Error checking WhatsApp availability: $e');
      return false;
    }
  }

  // Send SMS OTP using Twilio
  Future<Map<String, dynamic>> sendSMSOTP({
    required String phoneNumber,
    required String userType,
  }) async {
    _setLoading(true);
    
    try {
      // Ensure local storage is ready
      await _ensureInitialized();
      
      // Validate phone number
      if (!TwilioSmsService.isValidPhoneNumber(phoneNumber)) {
        return {
          'success': false,
          'message': 'Please enter a valid phone number',
        };
      }
      
      // Always normalize to E.164 for consistent keying
      final formattedPhone = TwilioSmsService.formatPhoneNumber(phoneNumber);
      
      // Resend cooldown: block resends within 60 seconds
      final existing = _authBox?.get('pending_otp_$formattedPhone');
      if (existing != null) {
        final lastTs = existing['timestamp'] as int? ?? 0;
        final now = DateTime.now().millisecondsSinceEpoch;
        final diffMs = now - lastTs;
        const cooldownMs = 60 * 1000; // 60 seconds
        if (diffMs < cooldownMs) {
          final remaining = ((cooldownMs - diffMs) / 1000).ceil();
          return {
            'success': false,
            'message': 'Please wait $remaining seconds before requesting a new OTP',
            'error_code': 'RESEND_COOLDOWN',
            'retry_after': remaining,
          };
        }
      }
      
      // Generate OTP
      final otp = TwilioSmsService.generateOTP();
      
      // Format phone number consistently for storage key
      // moved up: formattedPhone already defined
      
      // Store OTP temporarily (in production, use secure storage)
      
      await _authBox?.put('pending_otp_$formattedPhone', {
        'otp': otp,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'phone': formattedPhone,
        'user_type': userType,
      });
      
      // Send OTP via Twilio
      final result = await TwilioSmsService.sendOTP(
        phoneNumber: phoneNumber,
        otp: otp,
      );
      
      if (result['success']) {
        return {
          'success': true,
          'message': 'OTP sent to your phone number successfully',
          'phone': phoneNumber,
          'expires_in': 300, // 5 minutes
        };
      } else {
        return {
          'success': false,
          'message': result['message'] ?? 'Failed to send OTP',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to send OTP: ${e.toString()}',
      };
    } finally {
      _setLoading(false);
    }
  }

  // Verify SMS OTP and login/register user
  Future<Map<String, dynamic>> verifySMSOTPAndLogin({
    required String phoneNumber,
    required String otp,
    required String userType,
    String? name,
  }) async {
    _setLoading(true);
    
    try {
      // Ensure local storage is ready
      await _ensureInitialized();
      
      // Format phone number consistently for retrieval key
      final formattedPhone = TwilioSmsService.formatPhoneNumber(phoneNumber);
      
      // Get stored OTP data
      final storedData = _authBox?.get('pending_otp_$formattedPhone');
      
      if (storedData == null) {
        return {
          'success': false,
          'message': 'OTP expired or not found. Please request a new OTP.',
        };
      }
      
      final storedOTP = storedData['otp'];
      final timestamp = storedData['timestamp'];
      final now = DateTime.now().millisecondsSinceEpoch;
      
      // Check if OTP is expired (5 minutes)
        if (now - timestamp > 300000) {
          await _authBox?.delete('pending_otp_$formattedPhone');
          return {
            'success': false,
            'message': 'OTP has expired. Please request a new OTP.',
          };
        }
      
      // Verify OTP
      if (!TwilioSmsService.verifyOTP(otp, storedOTP)) {
        return {
          'success': false,
          'message': 'Invalid OTP. Please check and try again.',
        };
      }
      
      // Clear stored OTP
      await _authBox?.delete('pending_otp_$formattedPhone');
      
      // Check if user exists in our database
      final existingUserData = await SupabaseService.select(
        table: 'users',
        columns: '*',
        filter: 'eq:phone:$formattedPhone',
      );
      
      UserModel user;
      bool isNewUser = false;
      final existingUser = existingUserData.where((u) => u['phone'] == formattedPhone).firstOrNull;
      
      if (existingUser != null) {
        user = UserModel.fromJson(existingUser);
      } else {
        // Create new user profile
        // For SMS users, use phone number as ID and skip Supabase auth creation
        // since SMS verification is handled by Twilio
        final cleanPhone = formattedPhone.replaceAll(RegExp(r'[^0-9]'), '');
        final dummyEmail = 'sms_user_${cleanPhone}@rentme.local';
        
        // Generate a proper UUID for the user
        final uuid = const Uuid();
        final userId = uuid.v4();
        
        user = UserModel(
          id: userId,
          phone: formattedPhone,
          userType: userType,
          name: name ?? 'SMS User',
          email: dummyEmail,
          profileImage: '',
          isVerified: true, // SMS verified
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        // Save new user to Supabase users table directly
        try {
          await SupabaseService.insert(
            table: 'users',
            data: user.toSupabaseUsersJson(),
          );
          isNewUser = true;
        } catch (insertError) {
          debugPrint('Failed to insert user: $insertError');
          return {
            'success': false,
            'message': 'Failed to create user account. Please try again.',
            'error': insertError.toString(),
          };
        }
      }
      
      _authToken = user.id;
      _currentUser = user;
      _isAuthenticated = true;
      
      // Save to local storage
      await _saveUserData();
      
      notifyListeners();
      
      return {
        'success': true,
        'message': isNewUser ? 'Account created successfully' : 'Login successful',
        'user': user.toJson(),
        'token': _authToken,
        'is_new_user': isNewUser,
      };
      
    } catch (e) {
      return {
        'success': false,
        'message': 'SMS verification failed: ${e.toString()}',
      };
    } finally {
      _setLoading(false);
    }
  }

  // Verify OTP and login/register user
  Future<Map<String, dynamic>> verifyOTPAndLogin({
    required String email,
    required String otp,
    required String userType,
    String? phoneNumber,
  }) async {
    _setLoading(true);
    
    try {
      // Verify OTP with Supabase
      final authResponse = await SupabaseService.verifyOtp(
        email: email,
        token: otp,
        type: OtpType.email,
      );
      
      if (authResponse.user == null) {
        return {
          'success': false,
          'message': 'Invalid OTP or verification failed',
        };
      }
      
      final supabaseUser = authResponse.user!;
      bool isNewUser = false;
      
      // Check if user profile exists in our users table
      final existingUserData = await SupabaseService.select(
        table: 'users',
        columns: '*',
        filter: 'eq:id:${supabaseUser.id}',
      );
      
      UserModel user;
      final existingUser = existingUserData.where((u) => u['id'] == supabaseUser.id).firstOrNull;
      
      if (existingUser != null) {
        user = UserModel.fromJson(existingUser);
      } else {
        // Create new user profile
        user = UserModel(
          id: supabaseUser.id,
          phone: phoneNumber ?? '',
          userType: userType,
          name: supabaseUser.userMetadata?['name'] ?? '',
          email: supabaseUser.email ?? email,
          profileImage: supabaseUser.userMetadata?['avatar_url'] ?? '',
          isVerified: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        // Save new user to Supabase
        await SupabaseService.insert(
          table: 'users',
          data: user.toSupabaseUsersJson(),
        );
        isNewUser = true;
      }
      
      _authToken = supabaseUser.id;
      _currentUser = user;
      _isAuthenticated = true;
      
      // Save to local storage
      await _saveUserData();
      
      notifyListeners();
      
      return {
        'success': true,
        'message': isNewUser ? 'Account created successfully' : 'Login successful',
        'user': user.toJson(),
        'token': _authToken,
        'is_new_user': isNewUser,
      };
      
    } catch (e) {
      return {
        'success': false,
        'message': 'Verification failed. Please check your OTP and try again.',
        'error': e.toString(),
      };
    } finally {
      _setLoading(false);
    }
  }

  // Sign up with email and password
  Future<Map<String, dynamic>> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String userType,
    String? phoneNumber,
  }) async {
    _setLoading(true);
    
    try {
      final authResponse = await SupabaseService.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'user_type': userType,
          'phone': phoneNumber,
        },
      );
      
      if (authResponse.user == null) {
        return {
          'success': false,
          'message': 'Sign up failed. Please try again.',
        };
      }
      
      final supabaseUser = authResponse.user!;
      
      // Create user profile
      final user = UserModel(
        id: supabaseUser.id,
        phone: phoneNumber ?? '',
        userType: userType,
        name: name,
        email: email,
        profileImage: '',
        isVerified: supabaseUser.emailConfirmedAt != null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Save user to Supabase
      await SupabaseService.insert(
        table: 'users',
        data: user.toSupabaseUsersJson(),
      );
      
      _authToken = supabaseUser.id;
      _currentUser = user;
      _isAuthenticated = true;
      
      await _saveUserData();
      notifyListeners();
      
      return {
        'success': true,
        'message': 'Account created successfully. Please check your email for verification.',
        'user': user.toJson(),
        'token': _authToken,
        'is_new_user': true,
      };
      
    } catch (e) {
      return {
        'success': false,
        'message': 'Sign up failed. ${e.toString()}',
        'error': e.toString(),
      };
    } finally {
      _setLoading(false);
    }
  }
  
  // Sign in with email and password
  Future<Map<String, dynamic>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    
    try {
      final authResponse = await SupabaseService.signIn(
        email: email,
        password: password,
      );
      
      if (authResponse.user == null) {
        return {
          'success': false,
          'message': 'Invalid email or password.',
        };
      }
      
      final supabaseUser = authResponse.user!;
      
      // Get user profile from database
      final userData = await SupabaseService.select(
        table: 'users',
        columns: '*',
        filter: 'eq:id:${supabaseUser.id}',
      );
      
      final userProfile = userData.where((u) => u['id'] == supabaseUser.id).firstOrNull;
      
      if (userProfile == null) {
        return {
          'success': false,
          'message': 'User profile not found.',
        };
      }
      
      final user = UserModel.fromJson(userProfile);
      
      _authToken = supabaseUser.id;
      _currentUser = user;
      _isAuthenticated = true;
      
      await _saveUserData();
      notifyListeners();
      
      return {
        'success': true,
        'message': 'Login successful',
        'user': user.toJson(),
        'token': _authToken,
        'is_new_user': false,
      };
      
    } catch (e) {
      return {
        'success': false,
        'message': 'Login failed. Please check your credentials.',
        'error': e.toString(),
      };
    } finally {
      _setLoading(false);
    }
  }

  // Sign in with Google
  Future<Map<String, dynamic>> signInWithGoogle() async {
    _setLoading(true);
    
    try {
      // For now, return a placeholder response
      // This would integrate with Google Sign-In in a real implementation
      return {
        'success': false,
        'message': 'Google Sign-In not implemented yet',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Google Sign-In failed',
        'error': e.toString(),
      };
    } finally {
      _setLoading(false);
    }
  }

  // Update user profile
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> updates) async {
    if (_currentUser == null) {
      return {
        'success': false,
        'message': 'User not authenticated',
      };
    }
    
    _setLoading(true);
    
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Update user data
      _currentUser = _currentUser!.copyWith(
        name: updates['name'] ?? _currentUser!.name,
        email: updates['email'] ?? _currentUser!.email,
        profileImage: updates['profileImage'] ?? _currentUser!.profileImage,
        updatedAt: DateTime.now(),
      );
      
      // Save to local storage
      await _saveUserData();
      await _updateStoredUser(_currentUser!);
      
      notifyListeners();
      
      return {
        'success': true,
        'message': 'Profile updated successfully',
        'user': _currentUser!.toJson(),
      };
      
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to update profile',
        'error': e.toString(),
      };
    } finally {
      _setLoading(false);
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      // Sign out from Supabase
      await SupabaseService.signOut();
      
      // Clear local storage
      await _authBox?.clear();
      
      // Reset state
      _currentUser = null;
      _authToken = null;
      _isAuthenticated = false;
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error during logout: $e');
    }
  }

  // Delete account
  Future<Map<String, dynamic>> deleteAccount() async {
    if (_currentUser == null) {
      return {
        'success': false,
        'message': 'User not authenticated',
      };
    }
    
    _setLoading(true);
    
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));
      
      // Delete user from local storage
      await _deleteStoredUser(_currentUser!.id);
      
      // Logout
      await logout();
      
      return {
        'success': true,
        'message': 'Account deleted successfully',
      };
      
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to delete account',
        'error': e.toString(),
      };
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  String _generateOTPId() {
    return 'otp_${DateTime.now().millisecondsSinceEpoch}';
  }

  String _generateUserId() {
    return 'user_${DateTime.now().millisecondsSinceEpoch}';
  }

  String _generateAuthToken(String userId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final data = '$userId:$timestamp:${AppConstants.appName}';
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<UserModel?> _checkUserExists(String phoneNumber) async {
    try {
      final users = _userBox?.get('users', defaultValue: <String, dynamic>{});
      if (users != null && users[phoneNumber] != null) {
        return UserModel.fromJson(Map<String, dynamic>.from(users[phoneNumber]));
      }
      return null;
    } catch (e) {
      debugPrint('Error checking user existence: $e');
      return null;
    }
  }

  Future<void> _saveNewUser(UserModel user) async {
    try {
      final users = _userBox?.get('users', defaultValue: <String, dynamic>{}) ?? <String, dynamic>{};
      users[user.phoneNumber] = user.toJson();
      await _userBox?.put('users', users);
    } catch (e) {
      debugPrint('Error saving new user: $e');
    }
  }

  Future<void> _updateStoredUser(UserModel user) async {
    try {
      final users = _userBox?.get('users', defaultValue: <String, dynamic>{}) ?? <String, dynamic>{};
      users[user.phoneNumber] = user.toJson();
      await _userBox?.put('users', users);
    } catch (e) {
      debugPrint('Error updating stored user: $e');
    }
  }

  Future<void> _deleteStoredUser(String userId) async {
    try {
      final users = _userBox?.get('users', defaultValue: <String, dynamic>{}) ?? <String, dynamic>{};
      users.removeWhere((key, value) => value['id'] == userId);
      await _userBox?.put('users', users);
    } catch (e) {
      debugPrint('Error deleting stored user: $e');
    }
  }

  // Validate phone number
  bool isValidPhoneNumber(String phoneNumber) {
    final phoneRegex = RegExp(r'^[+]?[1-9]\d{1,14}$');
    return phoneRegex.hasMatch(phoneNumber.replaceAll(RegExp(r'[\s-()]'), ''));
  }

  // Format phone number
  String formatPhoneNumber(String phoneNumber) {
    String cleaned = phoneNumber.replaceAll(RegExp(r'[\s-()]'), '');
    if (cleaned.startsWith('91') && cleaned.length == 12) {
      return '+$cleaned';
    } else if (cleaned.length == 10) {
      return '+91$cleaned';
    }
    return cleaned;
  }
}