import 'package:otpless_flutter/otpless_flutter.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class WhatsAppOTPService {
  static final WhatsAppOTPService _instance = WhatsAppOTPService._internal();
  factory WhatsAppOTPService() => _instance;
  WhatsAppOTPService._internal();

  final Otpless _otplessFlutterPlugin = Otpless();
  bool _isInitialized = false;
  static const String appId = 'YOUR_OTPLESS_APP_ID'; // Replace with your actual App ID

  /// Initialize the service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Initialize OTPless with app ID
      await _otplessFlutterPlugin.initHeadless(appId);
      
      _isInitialized = true;
      print('WhatsApp OTP Service initialized successfully');
    } catch (e) {
      print('Error initializing WhatsApp OTP Service: $e');
      throw Exception('Failed to initialize WhatsApp OTP Service: $e');
    }
  }

  /// Open login page for WhatsApp authentication
  Future<Map<String, dynamic>> openLoginPage() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      Map<String, dynamic> arg = {'appId': appId};
      
      // Use a completer to handle the callback
      final completer = Completer<Map<String, dynamic>>();
      
      _otplessFlutterPlugin.openLoginPage((result) {
        completer.complete({
          'success': true,
          'message': 'Login page opened successfully',
          'data': result,
        });
      }, arg);
      
      return await completer.future;
    } catch (e) {
      print('Error opening login page: $e');
      return {
        'success': false,
        'message': 'Failed to open login page: $e',
        'error': e.toString(),
      };
    }
  }

  /// Start headless authentication with WhatsApp
  Future<Map<String, dynamic>> startHeadlessAuth() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      Map<String, dynamic> arg = {'channelType': 'WHATSAPP'};
      
      // Use a completer to handle the callback
      final completer = Completer<Map<String, dynamic>>();
      
      _otplessFlutterPlugin.startHeadless((result) {
        completer.complete({
          'success': true,
          'message': 'Headless authentication started',
          'data': result,
        });
      }, arg);
      
      return await completer.future;
    } catch (e) {
      print('Error starting headless auth: $e');
      return {
        'success': false,
        'message': 'Failed to start headless authentication: $e',
        'error': e.toString(),
      };
    }
  }

  /// Authenticate with WhatsApp using intent URL (legacy method)
  Future<Map<String, dynamic>> loginWithWhatsApp({
    required String intentUrl,
  }) async {
    try {
      // For now, use the open login page method
      return await openLoginPage();
    } catch (e) {
      print('Error with WhatsApp login: $e');
      return {
        'success': false,
        'message': 'Failed to login with WhatsApp: $e',
        'error': e.toString(),
      };
    }
  }

  /// Send OTP via WhatsApp (using headless method)
  Future<Map<String, dynamic>> sendWhatsAppOTP({
    required String phoneNumber,
    String? countryCode,
  }) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      // Format phone number with country code
      String formattedNumber = phoneNumber;
      if (countryCode != null && !phoneNumber.startsWith('+')) {
        formattedNumber = '$countryCode$phoneNumber';
      }
      if (!formattedNumber.startsWith('+')) {
        formattedNumber = '+91$formattedNumber'; // Default to India
      }

      Map<String, dynamic> arg = {
        'channelType': 'WHATSAPP',
        'phone': formattedNumber,
      };
      
      final completer = Completer<Map<String, dynamic>>();
      
      _otplessFlutterPlugin.startHeadless((result) {
        if (result['success'] == true) {
          completer.complete({
            'success': true,
            'message': 'OTP sent successfully via WhatsApp',
            'orderId': result['orderId'],
            'phoneNumber': formattedNumber,
          });
        } else {
          completer.complete({
            'success': false,
            'message': result['message'] ?? 'Failed to send OTP',
          });
        }
      }, arg);
      
      return await completer.future;
    } catch (e) {
      print('Error sending WhatsApp OTP: $e');
      return {
        'success': false,
        'message': 'Failed to send WhatsApp OTP: $e',
      };
    }
  }

  /// Verify OTP received via WhatsApp (using headless method)
  Future<Map<String, dynamic>> verifyWhatsAppOTP({
    required String phoneNumber,
    required String otp,
    required String orderId,
  }) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      Map<String, dynamic> arg = {
        'channelType': 'WHATSAPP',
        'phone': phoneNumber,
        'otp': otp,
        'orderId': orderId,
      };
      
      final completer = Completer<Map<String, dynamic>>();
      
      _otplessFlutterPlugin.startHeadless((result) {
        if (result['success'] == true) {
          completer.complete({
            'success': true,
            'message': 'OTP verified successfully',
            'userToken': result['token'],
            'phoneNumber': phoneNumber,
          });
        } else {
          completer.complete({
            'success': false,
            'message': result['message'] ?? 'Invalid OTP',
          });
        }
      }, arg);
      
      return await completer.future;
    } catch (e) {
      print('Error verifying WhatsApp OTP: $e');
      return {
        'success': false,
        'message': 'Failed to verify OTP: $e',
      };
    }
  }

  /// Alternative: Use WhatsApp Login (One-tap authentication)
  Future<Map<String, dynamic>> authenticateWithWhatsApp() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      return await startHeadlessAuth();
    } catch (e) {
      print('Error with WhatsApp authentication: $e');
      return {
        'success': false,
        'message': 'WhatsApp authentication failed: $e',
      };
    }
  }

  /// Check if WhatsApp is available on the device
  Future<bool> isWhatsAppAvailable() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }
      
      // Check if WhatsApp is installed
      return await _otplessFlutterPlugin.isWhatsAppInstalled();
    } catch (e) {
      print('Error checking WhatsApp availability: $e');
      return false;
    }
  }

  /// Get authentication stream (not available in current version)
  Stream<String> get authStream {
    // Return an empty stream for now as the current API doesn't support this
    return Stream<String>.empty();
  }

  /// Format phone number for display
  String formatPhoneNumber(String phoneNumber) {
    // Remove any non-digit characters except +
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Add country code if not present
    if (!cleaned.startsWith('+')) {
      cleaned = '+91$cleaned'; // Default to India
    }
    
    return cleaned;
  }

  /// Validate phone number format
  bool isValidPhoneNumber(String phoneNumber) {
    // Basic validation for Indian phone numbers
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    return cleaned.length >= 10 && cleaned.length <= 15;
  }
}