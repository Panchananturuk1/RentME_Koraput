import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../services/firebase_auth_service.dart';
import '../../services/whatsapp_otp_service.dart';

class FirebasePhoneLoginScreen extends StatefulWidget {
  final String userType;

  const FirebasePhoneLoginScreen({
    super.key,
    required this.userType,
  });

  @override
  State<FirebasePhoneLoginScreen> createState() => _FirebasePhoneLoginScreenState();
}

class _FirebasePhoneLoginScreenState extends State<FirebasePhoneLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isLoading = false;
  bool _isOTPMode = false;
  bool _isWhatsAppMode = false;
  String _verificationId = '';
  final FirebaseAuthService _authService = FirebaseAuthService.instance;
  final WhatsAppOTPService _whatsappService = WhatsAppOTPService();

  @override
  void initState() {
    super.initState();
    _authService.initialize();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _sendWhatsAppOTP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _isWhatsAppMode = true;
    });

    try {
      await _whatsappService.initialize();
      final result = await _whatsappService.sendWhatsAppOTP(phoneNumber: _phoneController.text);
      
      if (result['success']) {
        setState(() {
          _isOTPMode = true;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('OTP sent via WhatsApp to ${_phoneController.text}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed to send WhatsApp OTP'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _verifyWhatsAppOTP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _whatsappService.verifyWhatsAppOTP(
        otp: _otpController.text,
        phoneNumber: _phoneController.text,
      );
      
      if (result['success']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('WhatsApp OTP verified successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Navigate to appropriate screen based on user type
          if (widget.userType == AppConstants.userTypePassenger) {
            context.go('/passenger-dashboard');
          } else {
            context.go('/driver-dashboard');
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Invalid OTP'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _sendOTP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (kIsWeb) {
        // Web platform - use Twilio SMS
        final result = await _authService.signInWithPhoneNumber(
          _phoneController.text,
        );

        if (result['success']) {
          setState(() {
            _isOTPMode = true;
            _isLoading = false;
          });
          _showSnackBar('OTP sent to your phone via SMS');
        } else {
          setState(() {
            _isLoading = false;
          });
          _showSnackBar(result['message'] ?? 'Failed to send OTP', isError: true);
        }
      } else {
        // Mobile platforms - use verifyPhoneNumber
        final result = await _authService.sendPhoneOTP(
          _phoneController.text,
          onCodeSent: (verificationId) {
            setState(() {
              _verificationId = verificationId;
              _isOTPMode = true;
              _isLoading = false;
            });
            _showSnackBar('OTP sent to your phone');
          },
          onError: (error) {
            setState(() {
              _isLoading = false;
            });
            _showSnackBar(error, isError: true);
          },
        );

        if (!result['success']) {
          setState(() {
            _isLoading = false;
          });
          _showSnackBar(result['message'] ?? 'Failed to send OTP', isError: true);
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Error sending OTP: $e', isError: true);
    }
  }

  void _verifyOTP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic> result;

      if (kIsWeb) {
        // Web platform - confirm with Twilio OTP
        result = await _authService.confirmPhoneNumber(
          _otpController.text,
        );
      } else {
        // Mobile platforms - verify with verification ID
        result = await _authService.verifyPhoneOTP(
          _verificationId,
          _otpController.text,
        );
      }

      if (result['success']) {
        _showSnackBar('Phone verification successful!');
        
        // Navigate based on user type
        if (widget.userType == AppConstants.userTypePassenger) {
          context.go('/passenger-home');
        } else {
          context.go('/driver-home');
        }
      } else {
        _showSnackBar(result['message'] ?? 'OTP verification failed', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error verifying OTP: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.errorColor : AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),

                // Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80.w,
                        height: 80.w,
                        decoration: BoxDecoration(
                          color: const Color(0xFF34A853),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Icon(
                          Icons.phone_android,
                          size: 40.sp,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        _isOTPMode ? 'Enter OTP' : 'Phone Login',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        kIsWeb
                            ? 'Continue with Firebase Phone (Web)'
                            : 'Continue with Firebase Phone',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 48.h),

                // User Type Display
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        widget.userType == AppConstants.userTypePassenger
                            ? Icons.person
                            : Icons.drive_eta,
                        color: AppTheme.primaryColor,
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'Logging in as ${widget.userType}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32.h),

                // SMS notice for web
                if (kIsWeb && !_isOTPMode) ...[
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.sms_outlined,
                          color: Colors.green.shade600,
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            'You will receive a verification code via SMS to your phone number.',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],

                if (!_isOTPMode) ...[
                  // Phone Number Input
                  Text(
                    'Phone Number',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  CustomTextField(
                    controller: _phoneController,
                    hintText: '+1234567890',
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      if (!value.startsWith('+') || value.length < 10) {
                        return 'Please enter a valid phone number with country code';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Include country code (e.g., +91 for India)',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ] else ...[
                  // OTP Input
                  Text(
                    'Enter OTP',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'We have sent a 6-digit OTP to ${_phoneController.text}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  CustomTextField(
                    controller: _otpController,
                    hintText: 'Enter 6-digit OTP',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.lock,
                    maxLength: 6,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the OTP';
                      }
                      if (value.length != 6) {
                        return 'OTP must be 6 digits';
                      }
                      return null;
                    },
                  ),
                ],

                SizedBox(height: 32.h),

                // Action Button
                CustomButton(
                  text: _isOTPMode ? 'Verify OTP' : 'Send OTP',
                  onPressed: _isOTPMode ? _verifyOTP : _sendOTP,
                  isLoading: _isLoading && !_isWhatsAppMode,
                  backgroundColor: const Color(0xFF34A853),
                  textColor: Colors.white,
                ),

                SizedBox(height: 16.h),

                // OR Divider
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors.grey[300],
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Colors.grey[300],
                        thickness: 1,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16.h),

                // WhatsApp OTP Button
                CustomButton(
                  text: _isWhatsAppMode && _isOTPMode ? 'Verify WhatsApp OTP' : 'Send OTP via WhatsApp',
                  onPressed: _isWhatsAppMode && _isOTPMode ? _verifyWhatsAppOTP : _sendWhatsAppOTP,
                  isLoading: _isLoading && _isWhatsAppMode,
                  backgroundColor: const Color(0xFF25D366),
                  textColor: Colors.white,
                  icon: Icons.chat,
                ),

                if (_isOTPMode) ...[
                  SizedBox(height: 16.h),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _isOTPMode = false;
                          _isWhatsAppMode = false;
                          _otpController.clear();
                        });
                      },
                      child: Text(
                        'Change phone number',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}