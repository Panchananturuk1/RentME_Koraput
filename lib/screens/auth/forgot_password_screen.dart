import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:form_validator/form_validator.dart';
import '../../providers/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleForgotPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.resetPassword(_emailController.text.trim());
        
        setState(() {
          _emailSent = true;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0EA5E9),
              Color(0xFF0284C7),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Container(
                constraints: BoxConstraints(maxWidth: 400.w),
                padding: EdgeInsets.all(32.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back Button
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: Icon(
                              Icons.arrow_back,
                              color: const Color(0xFF374151),
                              size: 24.sp,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 16.h),
                      
                      // Header
                      if (!_emailSent) ...[
                        // Lock Icon
                        Container(
                          width: 64.w,
                          height: 64.w,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0EA5E9).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(32.r),
                          ),
                          child: Icon(
                            Icons.lock_reset,
                            color: const Color(0xFF0EA5E9),
                            size: 32.sp,
                          ),
                        ),
                        
                        SizedBox(height: 24.h),
                        
                        Text(
                          'Forgot Password?',
                          style: TextStyle(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF111827),
                          ),
                        ),
                        
                        SizedBox(height: 8.h),
                        
                        Text(
                          'No worries! Enter your email address and we\'ll send you a link to reset your password.',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: const Color(0xFF6B7280),
                            height: 1.5,
                          ),
                        ),
                        
                        SizedBox(height: 32.h),
                        
                        // Email Field
                        Text(
                          'Email Address',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF374151),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: ValidationBuilder()
                              .email('Please enter a valid email address')
                              .maxLength(50)
                              .build(),
                          decoration: InputDecoration(
                            hintText: 'Enter your email address',
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: const Color(0xFF9CA3AF),
                              size: 20.sp,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: const BorderSide(color: Color(0xFF0EA5E9), width: 2),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: const BorderSide(color: Color(0xFFDC2626)),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: const BorderSide(color: Color(0xFFDC2626), width: 2),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF9FAFB),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                          ),
                        ),
                        
                        SizedBox(height: 24.h),
                        
                        // Send Reset Link Button
                        SizedBox(
                          width: double.infinity,
                          height: 50.h,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleForgotPassword,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0EA5E9),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              disabledBackgroundColor: const Color(0xFF9CA3AF),
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    width: 20.w,
                                    height: 20.w,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Text(
                                    'Send Reset Link',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ] else ...[
                        // Success State
                        // Check Icon
                        Container(
                          width: 64.w,
                          height: 64.w,
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(32.r),
                          ),
                          child: Icon(
                            Icons.check_circle_outline,
                            color: const Color(0xFF10B981),
                            size: 32.sp,
                          ),
                        ),
                        
                        SizedBox(height: 24.h),
                        
                        Text(
                          'Check Your Email',
                          style: TextStyle(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF111827),
                          ),
                        ),
                        
                        SizedBox(height: 8.h),
                        
                        Text(
                          'We\'ve sent a password reset link to ${_emailController.text.trim()}',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: const Color(0xFF6B7280),
                            height: 1.5,
                          ),
                        ),
                        
                        SizedBox(height: 16.h),
                        
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F9FF),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: const Color(0xFFBAE6FD)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: const Color(0xFF0EA5E9),
                                    size: 20.sp,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Next Steps:',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF0EA5E9),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                '1. Check your email inbox\n2. Click the reset link in the email\n3. Create a new password\n4. Sign in with your new password',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: const Color(0xFF374151),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        SizedBox(height: 24.h),
                        
                        // Resend Email Button
                        SizedBox(
                          width: double.infinity,
                          height: 50.h,
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _emailSent = false;
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF0EA5E9),
                              side: const BorderSide(color: Color(0xFF0EA5E9)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            child: Text(
                              'Send Another Email',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                      
                      SizedBox(height: 24.h),
                      
                      // Back to Login Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.arrow_back,
                            color: const Color(0xFF6B7280),
                            size: 16.sp,
                          ),
                          SizedBox(width: 4.w),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'Back to Sign In',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: const Color(0xFF0EA5E9),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}