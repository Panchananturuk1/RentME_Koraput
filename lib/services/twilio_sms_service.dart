import 'dart:math';
import 'package:twilio_flutter/twilio_flutter.dart';
import '../core/constants/app_config.dart';

class TwilioSmsService {
  // Use environment-based credentials from AppConfig
  static String get accountSid => AppConfig.twilioAccountSid;
  static String get authToken => AppConfig.twilioAuthToken;
  static String get twilioPhoneNumber => AppConfig.twilioPhoneNumber;
  
  static TwilioFlutter? _twilioFlutter;
  
  /// Initialize Twilio service (non-throwing). If not configured, leaves service uninitialized.
  static void initialize() {
    if (!AppConfig.isTwilioConfigured) {
      // Not configured; keep uninitialized and let callers handle gracefully
      _twilioFlutter = null;
      return;
    }
    
    // Debug logging for credentials (masked for security)
    print('Twilio Config - SID: ${accountSid.substring(0, 6)}...${accountSid.substring(accountSid.length - 4)}, Phone: $twilioPhoneNumber');
    
    _twilioFlutter = TwilioFlutter(
      accountSid: accountSid,
      authToken: authToken,
      twilioNumber: twilioPhoneNumber,
    );
  }
  
  /// Send OTP via SMS using Twilio
  static Future<Map<String, dynamic>> sendOTP({
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      // Check if Twilio is configured
      if (!AppConfig.isTwilioConfigured) {
        return {
          'success': false,
          'message': 'Twilio SMS service is not configured. Please contact support.',
          'error_code': 'TWILIO_NOT_CONFIGURED',
        };
      }
      
      if (_twilioFlutter == null) {
        initialize();
      }
      
      // Validate phone number
      if (!isValidPhoneNumber(phoneNumber)) {
        return {
          'success': false,
          'message': 'Invalid phone number format',
          'error_code': 'INVALID_PHONE_NUMBER',
        };
      }
      
      // Format phone number to E.164 format
      String formattedPhone = formatPhoneNumber(phoneNumber);
      
      // Create the message body
      String message = 'Your ${AppConfig.appName} verification code is: $otp. Valid for ${AppConfig.otpExpiryMinutes} minutes. Do not share this code with anyone.';
      
      // Send the SMS
      TwilioResponse response = await _twilioFlutter!.sendSMS(
        toNumber: formattedPhone,
        messageBody: message,
      );
      
      // Debug logging for response
      print('Twilio Response - Code: ${response.responseCode}');
      print('Twilio Response Object: $response');
      
      // Check if SMS was sent successfully
      // Based on twilio_flutter documentation, check responseCode for SMS sending
      if (response.responseCode == 200 || response.responseCode == 201) {
        return {
          'success': true,
          'message': 'OTP sent successfully',
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to send SMS. Response code: ${response.responseCode}',
          'error_code': 'SMS_SEND_FAILED',
          'response_code': response.responseCode,
        };
      }
      
    } catch (e) {
      return {
        'success': false,
        'message': 'Error sending OTP: ${e.toString()}',
        'error_code': 'EXCEPTION',
      };
    }
  }
  
  /// Generate a random 6-digit OTP (zero-padded)
  static String generateOTP() {
    final rng = Random.secure();
    final code = rng.nextInt(1000000); // 0..999999
    return code.toString().padLeft(6, '0');
  }
  
  /// Format phone number to E.164 format
  static String formatPhoneNumber(String phoneNumber) {
    // Remove all non-digit characters
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Add country code if not present (assuming India +91)
    if (cleaned.length == 10) {
      cleaned = '91$cleaned';
    }
    
    // Add + prefix
    if (!cleaned.startsWith('+')) {
      cleaned = '+$cleaned';
    }
    
    return cleaned;
  }
  
  /// Verify OTP (simple implementation - in production, use more secure methods)
  static bool verifyOTP(String enteredOTP, String sentOTP) {
    return enteredOTP.trim() == sentOTP.trim();
  }
  
  /// Check if phone number is valid
  static bool isValidPhoneNumber(String phoneNumber) {
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    return cleaned.length >= 10 && cleaned.length <= 15;
  }
  
  /// Get Twilio account info (for testing purposes)
  static Future<Map<String, dynamic>> getAccountInfo() async {
    try {
      if (_twilioFlutter == null) {
        initialize();
      }
      
      // Note: twilio_flutter package may not have direct account info method
      // This is a placeholder implementation
      return {
        'success': true,
        'message': 'Twilio service initialized successfully',
        'account_sid': accountSid,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error getting account info: ${e.toString()}',
      };
    }
  }
}