import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'twilio_sms_service.dart';

import '../firebase_options.dart';

class FirebaseAuthService {
  static FirebaseAuthService? _instance;
  static FirebaseAuthService get instance => _instance ??= FirebaseAuthService._();

  FirebaseAuthService._();

  late final FirebaseAuth _auth;
  bool _isInitialized = false;

  // Web-specific OTP data for phone auth (using Twilio instead of reCAPTCHA)
  Map<String, dynamic>? _webOTPData;

  Future<void> initialize() async {
    if (_isInitialized) return;
    if (Firebase.apps.isEmpty) {
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } catch (_) {
        // Fallback if options are not properly configured
        await Firebase.initializeApp();
      }
    }
    _auth = FirebaseAuth.instance;
    _isInitialized = true;
  }

  // Email/Password Authentication
  Future<Map<String, dynamic>> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        return {
          'success': true,
          'user': credential.user,
          'uid': credential.user!.uid,
          'email': credential.user!.email,
        };
      }
      
      return {
        'success': false,
        'message': 'Login failed',
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: $e',
      };
    }
  }

  Future<Map<String, dynamic>> signUpWithEmail(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        return {
          'success': true,
          'user': credential.user,
          'uid': credential.user!.uid,
          'email': credential.user!.email,
        };
      }
      
      return {
        'success': false,
        'message': 'Registration failed',
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: $e',
      };
    }
  }

  // Email Link (Passwordless) Authentication Helpers
  Future<Map<String, dynamic>> sendEmailLink({
    required String email,
    required ActionCodeSettings actionCodeSettings,
  }) async {
    try {
      await _auth.sendSignInLinkToEmail(
        email: email,
        actionCodeSettings: actionCodeSettings,
      );
      return {
        'success': true,
        'message': 'Sign-in link sent to $email',
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to send sign-in link: $e',
      };
    }
  }

  bool isSignInWithEmailLink(String link) {
    return _auth.isSignInWithEmailLink(link);
  }

  Future<Map<String, dynamic>> signInWithEmailLink({
    required String email,
    required String emailLink,
  }) async {
    try {
      final credential = await _auth.signInWithEmailLink(email: email, emailLink: emailLink);
      if (credential.user != null) {
        return {
          'success': true,
          'user': credential.user,
          'uid': credential.user!.uid,
          'email': credential.user!.email,
        };
      }
      return {
        'success': false,
        'message': 'Email link sign-in failed',
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: $e',
      };
    }
  }

  // Helper to construct ActionCodeSettings
  ActionCodeSettings buildActionCodeSettings({
    required String url,
    String? iOSBundleId,
    String? androidPackageName,
    bool androidInstallApp = true,
    String? androidMinimumVersion,
    String? dynamicLinkDomain,
    String? handleCodeInAppOverride, // not used; always true
  }) {
    return ActionCodeSettings(
      url: url,
      handleCodeInApp: true,
      iOSBundleId: iOSBundleId,
      androidPackageName: androidPackageName,
      androidInstallApp: androidInstallApp,
      androidMinimumVersion: androidMinimumVersion,
      dynamicLinkDomain: dynamicLinkDomain,
    );
  }

  // Phone Authentication
  Future<Map<String, dynamic>> sendPhoneOTP(
    String phoneNumber, {
    required void Function(String verificationId) onCodeSent,
    required void Function(String error) onError,
  }) async {
    try {
      if (kIsWeb) {
        // On web, use Twilio SMS instead of reCAPTCHA
        final otp = TwilioSmsService.generateOTP();
        final result = await TwilioSmsService.sendOTP(
          phoneNumber: phoneNumber,
          otp: otp,
        );
        
        if (result['success']) {
          // Store OTP temporarily for verification
          _webOTPData = {
            'otp': otp,
            'phoneNumber': phoneNumber,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          };
          onCodeSent('twilio_sms');
        } else {
          onError(result['message'] ?? 'Failed to send OTP');
          return result;
        }
      } else {
        await _auth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          timeout: const Duration(seconds: 60),
          verificationCompleted: (PhoneAuthCredential credential) async {
            // Auto-verification (Android)
            try {
              await _auth.signInWithCredential(credential);
              onCodeSent('auto_verified');
            } catch (e) {
              onError('Auto-verification failed: $e');
            }
          },
          verificationFailed: (FirebaseAuthException e) {
            onError(_getErrorMessage(e));
          },
          codeSent: (String verificationId, int? resendToken) {
            onCodeSent(verificationId);
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            // no-op
          },
        );
      }
      
      return {
        'success': true,
        'message': 'OTP sent successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to send OTP: $e',
      };
    }
  }

  Future<Map<String, dynamic>> verifyPhoneOTP(String verificationId, String smsCode) async {
    try {
      UserCredential authResult;
      if (kIsWeb) {
        if (_webOTPData == null) {
          return {
            'success': false,
            'message': 'No OTP verification in progress. Please request a new OTP.',
          };
        }
        
        // Check if OTP is expired (5 minutes)
        final now = DateTime.now().millisecondsSinceEpoch;
        final timestamp = _webOTPData!['timestamp'] as int;
        if (now - timestamp > 300000) {
          _webOTPData = null;
          return {
            'success': false,
            'message': 'OTP has expired. Please request a new OTP.',
          };
        }
        
        // Verify OTP
        final storedOTP = _webOTPData!['otp'] as String;
        if (!TwilioSmsService.verifyOTP(smsCode, storedOTP)) {
          return {
            'success': false,
            'message': 'Invalid OTP. Please check and try again.',
          };
        }
        
        // Clear stored OTP
        final phoneNumber = _webOTPData!['phoneNumber'] as String;
        _webOTPData = null;
        
        // Create a custom token or use anonymous auth for web
        // Since we verified the phone via Twilio, we can trust this user
        authResult = await _auth.signInAnonymously();
        
        // Update the user's phone number in their profile
        if (authResult.user != null) {
          await authResult.user!.updateDisplayName(phoneNumber);
        }
      } else {
        final credential = PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: smsCode,
        );
        authResult = await _auth.signInWithCredential(credential);
      }
      
      if (authResult.user != null) {
        return {
          'success': true,
          'user': authResult.user,
          'uid': authResult.user!.uid,
          'phone': authResult.user!.phoneNumber,
        };
      }
      
      return {
        'success': false,
        'message': 'OTP verification failed',
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: $e',
      };
    }
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null;

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Error message mapping
  // Web-specific phone authentication methods
  Future<Map<String, dynamic>> signInWithPhoneNumber(
    String phoneNumber, {
    String? recaptchaContainerId,
  }) async {
    try {
      if (!kIsWeb) {
        throw UnsupportedError('signInWithPhoneNumber is only supported on web');
      }
      
      // Use Twilio SMS instead of reCAPTCHA
      final otp = TwilioSmsService.generateOTP();
      final result = await TwilioSmsService.sendOTP(
        phoneNumber: phoneNumber,
        otp: otp,
      );
      
      if (result['success']) {
        // Store OTP temporarily for verification
        _webOTPData = {
          'otp': otp,
          'phoneNumber': phoneNumber,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        };
        return {
          'success': true,
          'message': 'OTP sent successfully',
        };
      } else {
        return result;
      }
    } catch (e) {
      print('Error in signInWithPhoneNumber: $e');
      return {
        'success': false,
        'message': 'Error sending OTP: $e',
      };
    }
  }

  Future<Map<String, dynamic>> confirmPhoneNumber(
    String smsCode,
  ) async {
    try {
      if (!kIsWeb) {
        throw UnsupportedError('confirmPhoneNumber is only supported on web');
      }
      
      if (_webOTPData == null) {
        return {
          'success': false,
          'message': 'No OTP verification in progress. Please request a new OTP.',
        };
      }
      
      // Check if OTP is expired (5 minutes)
      final now = DateTime.now().millisecondsSinceEpoch;
      final timestamp = _webOTPData!['timestamp'] as int;
      if (now - timestamp > 300000) {
        _webOTPData = null;
        return {
          'success': false,
          'message': 'OTP has expired. Please request a new OTP.',
        };
      }
      
      // Verify OTP
      final storedOTP = _webOTPData!['otp'] as String;
      if (!TwilioSmsService.verifyOTP(smsCode, storedOTP)) {
        return {
          'success': false,
          'message': 'Invalid OTP. Please check and try again.',
        };
      }
      
      // Clear stored OTP
      final phoneNumber = _webOTPData!['phoneNumber'] as String;
      _webOTPData = null;
      
      // Since we verified via Twilio, we can trust this user
      // For now, return success without Firebase auth to avoid API issues
      return {
        'success': true,
        'message': 'Phone verification successful',
        'phone': phoneNumber,
        'verified': true,
        'method': 'twilio_sms',
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: $e',
      };
    }
  }

  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'Email already registered';
      case 'operation-not-allowed':
        return 'Operation not allowed';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-phone-number':
        return 'Invalid phone number';
      case 'too-many-requests':
        return 'Too many requests. Please try again later';
      case 'invalid-verification-code':
        return 'Invalid verification code';
      case 'session-expired':
        return 'Session expired. Please try again';
      default:
        return e.message ?? 'An authentication error occurred';
    }
  }
}