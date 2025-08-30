import 'package:flutter/material.dart';
import 'dart:async';
import 'whatsapp_cloud_service.dart';

class WhatsAppOTPService {
  static final WhatsAppOTPService _instance = WhatsAppOTPService._internal();
  factory WhatsAppOTPService() => _instance;
  WhatsAppOTPService._internal();

  final WhatsAppCloudService _whatsappCloudService = WhatsAppCloudService();
  bool _isInitialized = false;
  
  // Store current OTP session data
  String? _currentOtpId;
  String? _currentPhoneNumber;

  /// Initialize the service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Check if WhatsApp Cloud API is configured
      if (!_whatsappCloudService.isConfigured) {
        throw Exception('WhatsApp Cloud API is not configured. Please check your environment variables.');
      }
      
      _isInitialized = true;
      print('WhatsApp OTP Service initialized successfully');
    } catch (e) {
      print('Error initializing WhatsApp OTP Service: $e');
      throw Exception('Failed to initialize WhatsApp OTP Service: $e');
    }
  }

  /// Check if WhatsApp Cloud API is configured
  bool get isConfigured => _whatsappCloudService.isConfigured;
  
  /// Get business profile information
  Future<Map<String, dynamic>> getBusinessProfile() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }
      
      return await _whatsappCloudService.getBusinessProfile();
    } catch (e) {
      print('Error getting business profile: $e');
      return {
        'success': false,
        'message': 'Failed to get business profile: $e',
        'error': e.toString(),
      };
    }
  }

  /// Check if WhatsApp is available (always true for Cloud API)
  Future<bool> isWhatsAppAvailable() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }
      
      return _whatsappCloudService.isConfigured;
    } catch (e) {
      print('Error checking WhatsApp availability: $e');
      return false;
    }
  }

  /// Send OTP via WhatsApp Cloud API
  Future<Map<String, dynamic>> sendWhatsAppOTP({
    required String phoneNumber,
    String? countryCode,
  }) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      // Format phone number
      String formattedNumber = phoneNumber;
      if (countryCode != null && !phoneNumber.startsWith('+')) {
        formattedNumber = '$countryCode$phoneNumber';
      }
      if (!formattedNumber.startsWith('+') && !formattedNumber.startsWith('91')) {
        formattedNumber = '+91$formattedNumber'; // Default to India
      }
      
      // Clean up any existing expired OTPs
      _whatsappCloudService.cleanupExpiredOTPs();
      
      final result = await _whatsappCloudService.sendOTP(formattedNumber);
      
      if (result['success'] == true) {
        _currentOtpId = result['otpId'];
        _currentPhoneNumber = result['phoneNumber'];
      }
      
      return result;
    } catch (e) {
      print('Error sending WhatsApp OTP: $e');
      return {
        'success': false,
        'message': 'Failed to send WhatsApp OTP: $e',
      };
    }
  }



  /// Verify OTP received via WhatsApp Cloud API
  Future<Map<String, dynamic>> verifyWhatsAppOTP({
    required String otp,
    String? otpId,
    String? phoneNumber,
  }) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      // Use provided otpId or the current session's otpId
      final sessionOtpId = otpId ?? _currentOtpId;
      
      if (sessionOtpId == null) {
        return {
          'success': false,
          'message': 'No active OTP session found. Please request a new OTP.',
        };
      }
      
      final result = await _whatsappCloudService.verifyOTP(sessionOtpId, otp);
      
      if (result['success'] == true) {
        // Clear current session data on successful verification
        _currentOtpId = null;
        _currentPhoneNumber = null;
      }
      
      return result;
    } catch (e) {
      print('Error verifying WhatsApp OTP: $e');
      return {
        'success': false,
        'message': 'Failed to verify OTP: $e',
      };
    }
  }

  /// Get current OTP session information
  Map<String, dynamic> getCurrentSession() {
    return {
      'hasActiveSession': _currentOtpId != null,
      'otpId': _currentOtpId,
      'phoneNumber': _currentPhoneNumber,
    };
  }

  /// Clear current OTP session
  void clearSession() {
    _currentOtpId = null;
    _currentPhoneNumber = null;
  }

  /// Clean up expired OTPs
  void cleanupExpiredOTPs() {
    _whatsappCloudService.cleanupExpiredOTPs();
  }

  /// Format phone number for display
  String formatPhoneNumber(String phoneNumber) {
    return _whatsappCloudService.formatPhoneNumberForDisplay(phoneNumber);
  }

  /// Validate phone number format
  bool isValidPhoneNumber(String phoneNumber) {
    return _whatsappCloudService.isValidPhoneNumber(phoneNumber);
  }
}