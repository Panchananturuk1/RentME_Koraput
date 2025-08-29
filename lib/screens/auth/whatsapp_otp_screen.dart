import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// Removed: import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../services/auth_service.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class WhatsAppOTPScreen extends StatefulWidget {
  final String phoneNumber;
  final String userType;
  final String? orderId;
  final String? name;
  final String? email;

  const WhatsAppOTPScreen({
    Key? key,
    required this.phoneNumber,
    required this.userType,
    this.orderId,
    this.name,
    this.email,
  }) : super(key: key);

  @override
  State<WhatsAppOTPScreen> createState() => _WhatsAppOTPScreenState();
}

class _WhatsAppOTPScreenState extends State<WhatsAppOTPScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  int _resendTimer = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    setState(() {
      _resendTimer = 60;
      _canResend = false;
    });
    
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _resendTimer--;
          if (_resendTimer <= 0) {
            _canResend = true;
          }
        });
      }
      return _resendTimer > 0 && mounted;
    });
  }

  Future<void> _verifyOTP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await AuthService().loginWithWhatsApp(
        userType: widget.userType,
      );

      if (result['success']) {
        // Check if user data is available (successful authentication)
        if (result['user'] != null) {
          // Navigate to appropriate home screen
          if (widget.userType == 'passenger') {
            context.go('/passenger-home');
          } else {
            context.go('/driver-home');
          }
        } else {
          setState(() {
            _errorMessage = 'Authentication initiated. Please complete the process in WhatsApp.';
          });
        }
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Verification failed';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resendOTP() async {
    if (!_canResend) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await AuthService().loginWithWhatsApp(
        userType: widget.userType,
      );

      if (result['success']) {
        _startResendTimer();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP sent successfully via WhatsApp'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Failed to resend OTP';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to resend OTP. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'WhatsApp Verification',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                
                // WhatsApp Icon
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF25D366),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Icon(
                      Icons.chat,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Title
                const Text(
                  'Enter WhatsApp OTP',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Subtitle
                Text(
                  'We sent a verification code to\n${widget.phoneNumber} via WhatsApp',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // OTP Input
                CustomTextField(
                  controller: _otpController,
                  labelText: 'Enter OTP',
                  hintText: 'Enter 6-digit code',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the OTP';
                    }
                    if (value.length != 6) {
                      return 'OTP must be 6 digits';
                    }
                    return null;
                  },
                  prefixIcon: Icons.lock_outline,
                ),
                
                const SizedBox(height: 16),
                
                // Error Message
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red[600], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red[600], fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                const SizedBox(height: 24),
                
                // Verify Button
                CustomButton(
                  text: 'Verify OTP',
                  onPressed: _isLoading ? null : _verifyOTP,
                  isLoading: _isLoading,
                ),
                
                const SizedBox(height: 24),
                
                // Resend OTP
                Center(
                  child: Column(
                    children: [
                      Text(
                        "Didn't receive the code?",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_canResend)
                        TextButton(
                          onPressed: _isLoading ? null : _resendOTP,
                          child: const Text(
                            'Resend OTP',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      else
                        Text(
                          'Resend in ${_resendTimer}s',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // WhatsApp Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.green[600], size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Make sure WhatsApp is installed and you can receive messages on ${widget.phoneNumber}',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}