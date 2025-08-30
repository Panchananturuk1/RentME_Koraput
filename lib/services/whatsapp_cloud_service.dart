import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class WhatsAppCloudService {
  static final WhatsAppCloudService _instance = WhatsAppCloudService._internal();
  factory WhatsAppCloudService() => _instance;
  WhatsAppCloudService._internal();

  // WhatsApp Cloud API Configuration
  static const String _baseUrl = 'https://graph.facebook.com/v18.0';
  static const String _accessToken = String.fromEnvironment(
    'WHATSAPP_ACCESS_TOKEN',
    defaultValue: 'EAAPyeNHVBWoBPTP7CPRZAbzTp03LIfhiZB1ae2OZAGREyRc1MFZCnF6sZBuRL7x768llQ8kZBDu0NZAqBiZCt1TTtXHbYGZCcBHplyiQcQ9knpKSojaQHET0895JtyQfmtOBjgdzb0EBE2tdHG15NtvY5ydXZCpO0LZBskZCXQvnZB9UiO69MhmjpNTZBZC6CPHl4rtUfXZB9gZDZD',
  );
  static const String _phoneNumberId = String.fromEnvironment(
    'WHATSAPP_PHONE_NUMBER_ID',
    defaultValue: '773616775832523',
  );
  static const String _businessAccountId = String.fromEnvironment(
    'WHATSAPP_BUSINESS_ACCOUNT_ID',
    defaultValue: '1336565927809632',
  );

  // Store OTP data temporarily
  final Map<String, Map<String, dynamic>> _otpStorage = {};

  /// Check if WhatsApp Cloud API is configured
  bool get isConfigured {
    return _accessToken.isNotEmpty && 
           _phoneNumberId.isNotEmpty && 
           _businessAccountId.isNotEmpty &&
           !_accessToken.contains('your_') &&
           !_phoneNumberId.contains('your_');
  }

  /// Generate a random 6-digit OTP
  String _generateOTP() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  /// Format phone number to WhatsApp format (remove + and ensure proper format)
  String _formatPhoneNumber(String phoneNumber) {
    // Remove all non-digit characters except +
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Remove + if present
    if (cleaned.startsWith('+')) {
      cleaned = cleaned.substring(1);
    }
    
    // Add country code if not present (default to India +91)
    if (cleaned.length == 10) {
      cleaned = '91$cleaned';
    }
    
    return cleaned;
  }

  /// Send OTP via WhatsApp
  Future<Map<String, dynamic>> sendOTP(String phoneNumber) async {
    try {
      if (!isConfigured) {
        return {
          'success': false,
          'message': 'WhatsApp Cloud API is not configured. Please check your environment variables.',
        };
      }

      final formattedNumber = _formatPhoneNumber(phoneNumber);
      final otp = _generateOTP();
      final otpId = '${formattedNumber}_${DateTime.now().millisecondsSinceEpoch}';

      // Store OTP data
      _otpStorage[otpId] = {
        'otp': otp,
        'phoneNumber': formattedNumber,
        'timestamp': DateTime.now(),
        'verified': false,
      };

      // Prepare WhatsApp message
      final messageData = {
        'messaging_product': 'whatsapp',
        'to': formattedNumber,
        'type': 'template',
        'template': {
          'name': 'otp_verification', // You need to create this template in WhatsApp Business Manager
          'language': {
            'code': 'en_US'
          },
          'components': [
            {
              'type': 'body',
              'parameters': [
                {
                  'type': 'text',
                  'text': otp
                }
              ]
            }
          ]
        }
      };

      // If template is not available, use text message (for testing)
      final fallbackMessageData = {
        'messaging_product': 'whatsapp',
        'to': formattedNumber,
        'type': 'text',
        'text': {
          'body': 'Your RentME Koraput verification code is: $otp\n\nThis code will expire in 5 minutes. Do not share this code with anyone.'
        }
      };

      final url = '$_baseUrl/$_phoneNumberId/messages';
      final headers = {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      };

      // Try template first, fallback to text message
      http.Response response;
      try {
        response = await http.post(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(messageData),
        );
      } catch (e) {
        // Fallback to text message
        response = await http.post(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(fallbackMessageData),
        );
      }

      if (kDebugMode) {
        print('WhatsApp API Response: ${response.statusCode}');
        print('WhatsApp API Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'message': 'OTP sent successfully via WhatsApp',
          'otpId': otpId,
          'phoneNumber': formattedNumber,
          'messageId': responseData['messages']?[0]?['id'],
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': 'Failed to send WhatsApp message: ${errorData['error']?['message'] ?? 'Unknown error'}',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending WhatsApp OTP: $e');
      }
      return {
        'success': false,
        'message': 'Failed to send WhatsApp OTP: $e',
      };
    }
  }

  /// Verify OTP
  Future<Map<String, dynamic>> verifyOTP(String otpId, String enteredOTP) async {
    try {
      if (!_otpStorage.containsKey(otpId)) {
        return {
          'success': false,
          'message': 'Invalid or expired OTP session',
        };
      }

      final otpData = _otpStorage[otpId]!;
      final storedOTP = otpData['otp'] as String;
      final timestamp = otpData['timestamp'] as DateTime;
      final phoneNumber = otpData['phoneNumber'] as String;

      // Check if OTP is expired (5 minutes)
      if (DateTime.now().difference(timestamp).inMinutes > 5) {
        _otpStorage.remove(otpId);
        return {
          'success': false,
          'message': 'OTP has expired. Please request a new one.',
        };
      }

      // Check if OTP matches
      if (enteredOTP == storedOTP) {
        // Mark as verified and remove from storage
        _otpStorage[otpId]!['verified'] = true;
        _otpStorage.remove(otpId);
        
        return {
          'success': true,
          'message': 'OTP verified successfully',
          'phoneNumber': phoneNumber,
        };
      } else {
        return {
          'success': false,
          'message': 'Invalid OTP. Please try again.',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error verifying WhatsApp OTP: $e');
      }
      return {
        'success': false,
        'message': 'Failed to verify OTP: $e',
      };
    }
  }

  /// Get business profile information
  Future<Map<String, dynamic>> getBusinessProfile() async {
    try {
      if (!isConfigured) {
        return {
          'success': false,
          'message': 'WhatsApp Cloud API is not configured',
        };
      }

      final url = '$_baseUrl/$_businessAccountId';
      final headers = {
        'Authorization': 'Bearer $_accessToken',
      };

      final response = await http.get(Uri.parse(url), headers: headers);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to get business profile',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error getting business profile: $e',
      };
    }
  }

  /// Clean up expired OTPs
  void cleanupExpiredOTPs() {
    final now = DateTime.now();
    _otpStorage.removeWhere((key, value) {
      final timestamp = value['timestamp'] as DateTime;
      return now.difference(timestamp).inMinutes > 5;
    });
  }

  /// Format phone number for display
  String formatPhoneNumberForDisplay(String phoneNumber) {
    final formatted = _formatPhoneNumber(phoneNumber);
    if (formatted.startsWith('91') && formatted.length == 12) {
      return '+91 ${formatted.substring(2, 7)} ${formatted.substring(7)}';
    }
    return '+$formatted';
  }

  /// Validate phone number
  bool isValidPhoneNumber(String phoneNumber) {
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    return cleaned.length >= 10 && cleaned.length <= 15;
  }
}