import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _user != null;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    _user = AuthService.currentUser;
    
    // Listen to auth state changes
    AuthService.authStateChanges.listen((AuthState data) {
      print('🔔 Auth state change: ${data.event}');
      print('Session exists: ${data.session != null}');
      print('User exists: ${data.session?.user != null}');
      
      _user = data.session?.user;
      
      // Handle password recovery event
      if (data.event == AuthChangeEvent.passwordRecovery) {
        print('🔑 PASSWORD_RECOVERY event detected!');
        print('User is now authenticated for password reset');
        // The user is now logged in and can update their password
        // The UI should already be on the reset password screen from URL parsing
      } else if (data.event == AuthChangeEvent.signedIn) {
        print('✅ User signed in');
      } else if (data.event == AuthChangeEvent.signedOut) {
        print('👋 User signed out');
      }
      
      notifyListeners();
    });
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final response = await AuthService.signUp(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
      );

      if (response.user != null) {
        _user = response.user;
        notifyListeners();
        return true;
      } else {
        _setError('Failed to create account');
        return false;
      }
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final response = await AuthService.signIn(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _user = response.user;
        notifyListeners();
        return true;
      } else {
        _setError('Failed to sign in');
        return false;
      }
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      _setLoading(true);
      _setError(null);

      await AuthService.signOut();
      _user = null;
      notifyListeners();
    } on AuthException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('An unexpected error occurred: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _setError(null);

      await AuthService.resetPassword(email);
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updatePassword(String newPassword) async {
    try {
      _setLoading(true);
      _setError(null);

      await AuthService.updatePassword(newPassword);
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  String get userDisplayName {
    if (_user?.userMetadata?['full_name'] != null) {
      return _user!.userMetadata!['full_name'];
    }
    return _user?.email?.split('@').first ?? 'User';
  }

  String? get userEmail => _user?.email;
  String? get userPhoneNumber => _user?.userMetadata?['phone_number'];
  bool get isEmailVerified => AuthService.isEmailVerified;

  // Set session with refresh token
  Future<bool> setSession({
    required String refreshToken,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final response = await AuthService.setSession(
        refreshToken: refreshToken,
      );
      
      if (response.user != null) {
        _user = response.user;
        notifyListeners();
        return true;
      }
      return false;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Verify OTP and update password (for code-based reset)
  Future<bool> verifyOtpAndUpdatePassword({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final response = await AuthService.verifyOtpAndUpdatePassword(
        email: email,
        token: token,
        newPassword: newPassword,
      );
      
      if (response.user != null) {
        _user = response.user;
        notifyListeners();
        return true;
      }
      return false;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Simplified password reset for authenticated users
  Future<bool> updatePasswordForAuthenticatedUser(String newPassword) async {
    try {
      print('🚀 AuthProvider: Updating password for authenticated user');
      print('Current user: ${_user?.email}');
      
      final success = await AuthService.updatePasswordForAuthenticatedUser(newPassword);
      
      if (success) {
        print('✅ AuthProvider: Password updated successfully');
        // Refresh user state
        _user = AuthService.currentUser;
        notifyListeners();
      } else {
        print('❌ AuthProvider: Password update failed');
      }
      
      return success;
    } catch (e) {
      print('🔥 AuthProvider: ${e.runtimeType}: $e');
      throw e;
    }
  }
}