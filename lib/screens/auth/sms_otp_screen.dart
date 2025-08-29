import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// Removed: import 'package:provider/provider.dart';
import 'dart:async';
import '../../services/auth_service.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../passenger/passenger_home_screen.dart';
import '../driver/driver_home_screen.dart';

class SmsOtpScreen extends StatefulWidget {
  final String phoneNumber;
  final String userType;
  final String? userName;
  final bool isNewUser;
  
  const SmsOtpScreen({
    Key? key,
    required this.phoneNumber,
    required this.userType,
    this.userName,
    this.isNewUser = false,
  }) : super(key: key);

  @override
  State<SmsOtpScreen> createState() => _SmsOtpScreenState();
}

class _SmsOtpScreenState extends State<SmsOtpScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );
  
  bool _isLoading = false;
  bool _canResend = false;
  Timer? _resendTimer;
  int _resendCountdown = 60;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _canResend = false;
      _resendCountdown = 60;
    });
    
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  Future<void> _verifyOTP() async {
    final otp = _otpControllers.map((controller) => controller.text).join();
    
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the complete 6-digit OTP'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = AuthService();
      final result = await authService.verifySMSOTPAndLogin(
        phoneNumber: widget.phoneNumber,
        otp: otp,
        userType: widget.userType,
        name: widget.userName,
      );

      if (result['success']) {
        if (mounted) {
          // Navigate to appropriate home screen
          if (widget.userType == 'passenger') {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const PassengerHomeScreen(),
              ),
              (route) => false,
            );
          } else {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const DriverHomeScreen(),
              ),
              (route) => false,
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'OTP verification failed'),
              backgroundColor: Colors.red,
            ),
          );
          
          // Clear OTP fields on error
          for (var controller in _otpControllers) {
            controller.clear();
          }
          _focusNodes[0].requestFocus();
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
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resendOTP() async {
    if (!_canResend) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = AuthService();
      final result = await authService.sendSMSOTP(
        phoneNumber: widget.phoneNumber,
        userType: widget.userType,
      );

      if (result['success']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('OTP sent successfully'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Clear OTP fields and restart timer
          for (var controller in _otpControllers) {
            controller.clear();
          }
          _focusNodes[0].requestFocus();
          _startResendTimer();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed to resend OTP'),
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
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onOtpChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    
    // Auto-verify when all fields are filled
    if (index == 5 && value.isNotEmpty) {
      final otp = _otpControllers.map((controller) => controller.text).join();
      if (otp.length == 6) {
        _verifyOTP();
      }
    }
  }

  Widget _buildOtpField(int index) {
    return Container(
      width: 50,
      height: 60,
      decoration: BoxDecoration(
        border: Border.all(
          color: _focusNodes[index].hasFocus 
              ? AppTheme.primaryColor 
              : Colors.grey[300]!,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: Theme.of(context).textTheme.headlineMedium!.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (value) => _onOtpChanged(value, index),
        onTap: () {
          _otpControllers[index].selection = TextSelection.fromPosition(
            TextPosition(offset: _otpControllers[index].text.length),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'SMS Verification',
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              
              // Header
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Icon(
                  Icons.sms_outlined,
                  size: 40,
                  color: AppTheme.primaryColor,
                ),
              ),
              
              const SizedBox(height: 24),
              
              Text(
                'Enter Verification Code',
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'We sent a 6-digit code to',
                style: TextStyle(
                   fontSize: 16,
                   color: AppTheme.textSecondary,
                ),
              ),
              
              const SizedBox(height: 4),
              
              Text(
                widget.phoneNumber,
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // OTP Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  6,
                  (index) => _buildOtpField(index),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Verify Button
              CustomButton(
                text: 'Verify OTP',
                onPressed: _isLoading ? null : _verifyOTP,
                isLoading: _isLoading,
                icon: Icons.verified_user,
              ),
              
              const SizedBox(height: 24),
              
              // Resend OTP
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive the code? ",
                    style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: _canResend ? _resendOTP : null,
                    child: Text(
                      _canResend 
                          ? 'Resend OTP'
                          : 'Resend in ${_resendCountdown}s',
                      style: TextStyle(
                         color: _canResend 
                              ? AppTheme.primaryColor 
                              : AppTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                        decoration: _canResend 
                            ? TextDecoration.underline 
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Info Container
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'The verification code will expire in 5 minutes. Please enter it as soon as you receive it.',
                        style: TextStyle(
                           fontSize: 14,
                           color: AppTheme.textSecondary,
                         ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}