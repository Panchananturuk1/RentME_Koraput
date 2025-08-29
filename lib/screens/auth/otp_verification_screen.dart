import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../services/auth_service.dart';

class OTPVerificationScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const OTPVerificationScreen({
    super.key,
    required this.data,
  });
  
  String get email => data['email'] ?? '';
  String get userType => data['userType'] ?? AppConstants.userTypePassenger;

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen>
    with TickerProviderStateMixin {
  final List<TextEditingController> _otpControllers = 
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = 
      List.generate(6, (index) => FocusNode());
  
  bool _isLoading = false;
  bool _isResending = false;
  int _resendTimer = 30;
  late AnimationController _timerAnimationController;
  late AnimationController _slideAnimationController;
  late Animation<Offset> _slideAnimation;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startResendTimer();
  }

  void _initializeAnimations() {
    _timerAnimationController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    );

    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _slideAnimationController.forward();
  }

  void _startResendTimer() {
    _timerAnimationController.forward();
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _resendTimer > 0) {
        setState(() {
          _resendTimer--;
        });
        _startResendTimer();
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    _timerAnimationController.dispose();
    _slideAnimationController.dispose();
    super.dispose();
  }

  void _onOTPChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    // Auto-verify when all fields are filled
    if (_isOTPComplete()) {
      _verifyOTP();
    }
  }

  bool _isOTPComplete() {
    return _otpControllers.every((controller) => controller.text.isNotEmpty);
  }

  String _getOTPCode() {
    return _otpControllers.map((controller) => controller.text).join();
  }

  Future<void> _verifyOTP() async {
    if (!_isOTPComplete()) {
      _showSnackBar('Please enter complete OTP', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final otpCode = _getOTPCode();
      
      final result = await _authService.verifyOTPAndLogin(
        email: widget.email,
        otp: otpCode,
        userType: widget.userType,
      );
      
      if (result['success']) {
        _showSnackBar('OTP verified successfully!');
        
        // Navigate based on user type
        if (widget.userType == AppConstants.userTypePassenger) {
          context.go('/passenger-home');
        } else {
          context.go('/driver-home');
        }
      } else {
        _showSnackBar(result['message'] ?? 'Invalid OTP. Please try again.', isError: true);
        _clearOTP();
      }
    } catch (e) {
      _showSnackBar('Verification failed: $e', isError: true);
      _clearOTP();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resendOTP() async {
    if (_resendTimer > 0) return;

    setState(() {
      _isResending = true;
    });

    try {
      final result = await _authService.sendOTP(
        widget.email,
        widget.userType,
      );
      
      if (result['success']) {
        _showSnackBar('OTP sent successfully!');
        
        setState(() {
          _resendTimer = 30;
        });
        
        _timerAnimationController.reset();
        _startResendTimer();
        _clearOTP();
      } else {
        _showSnackBar(result['message'] ?? 'Failed to resend OTP', isError: true);
      }
    } catch (e) {
      _showSnackBar('Failed to resend OTP: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  void _clearOTP() {
    for (var controller in _otpControllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
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
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: SlideTransition(
          position: _slideAnimation,
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20.h),
                
                // Header
                _buildHeader(),
                
                SizedBox(height: 40.h),
                
                // OTP Input Fields
                _buildOTPFields(),
                
                SizedBox(height: 30.h),
                
                // Resend Timer
                _buildResendSection(),
                
                SizedBox(height: 40.h),
                
                // Verify Button
                _buildVerifyButton(),
                
                const Spacer(),
                
                // Help Text
                _buildHelpText(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80.w,
          height: 80.w,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.email_outlined,
            size: 40.sp,
            color: AppTheme.primaryColor,
          ),
        ),
        
        SizedBox(height: 24.h),
        
        Text(
          'Verify Your Email',
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        
        SizedBox(height: 8.h),
        
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              fontSize: 16.sp,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
            children: [
              const TextSpan(text: 'Enter the 6-digit code sent to\n'),
              TextSpan(
                text: widget.email,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOTPFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) {
        return Container(
          width: 50.w,
          height: 60.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: _focusNodes[index].hasFocus
                  ? AppTheme.primaryColor
                  : Colors.grey[300]!,
              width: _focusNodes[index].hasFocus ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _otpControllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: const InputDecoration(
              border: InputBorder.none,
              counterText: '',
            ),
            onChanged: (value) => _onOTPChanged(value, index),
          ),
        );
      }),
    );
  }

  Widget _buildResendSection() {
    return Column(
      children: [
        if (_resendTimer > 0) ...[
          Text(
            'Resend code in ${_resendTimer}s',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          LinearProgressIndicator(
            value: (30 - _resendTimer) / 30,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppTheme.primaryColor,
            ),
          ),
        ] else ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Didn't receive the code? ",
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppTheme.textSecondary,
                ),
              ),
              GestureDetector(
                onTap: _isResending ? null : _resendOTP,
                child: Text(
                  _isResending ? 'Sending...' : 'Resend',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: _isResending 
                        ? AppTheme.textSecondary 
                        : AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildVerifyButton() {
    return CustomButton(
      text: 'Verify & Continue',
      onPressed: _isOTPComplete() ? _verifyOTP : null,
      isLoading: _isLoading,
      width: double.infinity,
    );
  }

  Widget _buildHelpText() {
    return Text(
      'Having trouble? Contact support',
      style: TextStyle(
        fontSize: 14.sp,
        color: AppTheme.textSecondary,
      ),
    );
  }
}