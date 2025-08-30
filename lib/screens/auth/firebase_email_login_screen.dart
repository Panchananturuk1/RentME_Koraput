import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../services/firebase_auth_service.dart';

class FirebaseEmailLoginScreen extends StatefulWidget {
  final String userType;

  const FirebaseEmailLoginScreen({
    super.key,
    required this.userType,
  });

  @override
  State<FirebaseEmailLoginScreen> createState() => _FirebaseEmailLoginScreenState();
}

class _FirebaseEmailLoginScreenState extends State<FirebaseEmailLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isSignUpMode = false;
  bool _isEmailLinkMode = false;
  final FirebaseAuthService _authService = FirebaseAuthService.instance;

  @override
  void initState() {
    super.initState();
    _authService.initialize();
    _checkForEmailLink();
  }

  void _checkForEmailLink() async {
    // Check if this is a returning user from email link
    final prefs = await SharedPreferences.getInstance();
    final pendingEmail = prefs.getString('pending_email_link');
    
    if (pendingEmail != null) {
      final currentUrl = Uri.base.toString();
      if (_authService.isSignInWithEmailLink(currentUrl)) {
        _handleEmailLinkSignIn(pendingEmail, currentUrl);
      }
    }
  }

  void _handleEmailLinkSignIn(String email, String emailLink) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.signInWithEmailLink(
        email: email,
        emailLink: emailLink,
      );

      if (result['success']) {
        // Clear pending email
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('pending_email_link');
        
        _showSnackBar('Email link sign-in successful!');
        
        // Navigate based on user type
        if (widget.userType == AppConstants.userTypePassenger) {
          context.go('/passenger-home');
        } else {
          context.go('/driver-home');
        }
      } else {
        _showSnackBar(result['message'] ?? 'Email link sign-in failed', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error with email link: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic> result;

      if (_isEmailLinkMode) {
        // Send email link
        await _sendEmailLink();
        return;
      }

      if (_isSignUpMode) {
        // Sign up
        result = await _authService.signUpWithEmail(
          _emailController.text,
          _passwordController.text,
        );
      } else {
        // Login
        result = await _authService.signInWithEmail(
          _emailController.text,
          _passwordController.text,
        );
      }

      if (result['success']) {
        _showSnackBar(
          _isSignUpMode ? 'Registration successful!' : 'Login successful!',
        );
        
        // Navigate based on user type
        if (widget.userType == AppConstants.userTypePassenger) {
          context.go('/passenger-home');
        } else {
          context.go('/driver-home');
        }
      } else {
        _showSnackBar(result['message'] ?? 'Authentication failed', isError: true);
      }
    } catch (e) {
      _showSnackBar('An error occurred: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _sendEmailLink() async {
    try {
      final actionCodeSettings = _authService.buildActionCodeSettings(
        url: Uri.base.toString(),
        androidPackageName: 'com.example.rentme_koraput',
        iOSBundleId: 'com.example.rentmeKoraput',
      );

      final result = await _authService.sendEmailLink(
        email: _emailController.text,
        actionCodeSettings: actionCodeSettings,
      );

      if (result['success']) {
        // Store email for later verification
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('pending_email_link', _emailController.text);
        
        _showSnackBar('Sign-in link sent to ${_emailController.text}. Check your email!');
      } else {
        _showSnackBar(result['message'] ?? 'Failed to send email link', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error sending email link: $e', isError: true);
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
                          color: const Color(0xFFFBBC04),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Icon(
                          Icons.email,
                          size: 40.sp,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        _isEmailLinkMode 
                            ? 'Email Link Sign-In'
                            : _isSignUpMode 
                                ? 'Create Account' 
                                : 'Welcome Back',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        _isEmailLinkMode
                            ? 'Sign in without password'
                            : 'Continue with Firebase Email',
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

                // Email Input
                Text(
                  'Email Address',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                CustomTextField(
                  controller: _emailController,
                  hintText: 'Enter your email address',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 16.h),

                // Password Input
                Text(
                  'Password',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                CustomTextField(
                  controller: _passwordController,
                  hintText: 'Enter your password',
                  prefixIcon: Icons.lock,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),

                if (_isSignUpMode && !_isEmailLinkMode) ...[
                  SizedBox(height: 16.h),
                  Text(
                    'Confirm Password',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  CustomTextField(
                    controller: _confirmPasswordController,
                    hintText: 'Confirm your password',
                    prefixIcon: Icons.lock,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                ],

                SizedBox(height: 32.h),

                // Auth Button
                CustomButton(
                  text: _isEmailLinkMode 
                      ? 'Send Sign-In Link'
                      : _isSignUpMode 
                          ? 'Create Account' 
                          : 'Login',
                  onPressed: _handleAuth,
                  isLoading: _isLoading,
                  backgroundColor: const Color(0xFFFBBC04),
                  textColor: Colors.black,
                ),

                SizedBox(height: 16.h),

                // Email Link Toggle
                if (!_isSignUpMode) ...[
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isEmailLinkMode = !_isEmailLinkMode;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.primaryColor),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isEmailLinkMode ? Icons.lock : Icons.link,
                              size: 16.sp,
                              color: AppTheme.primaryColor,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              _isEmailLinkMode 
                                  ? 'Use Password Instead'
                                  : 'Sign In with Email Link',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],

                SizedBox(height: 24.h),

                // Toggle between login and signup
                if (!_isEmailLinkMode) ...[
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isSignUpMode
                              ? 'Already have an account? '
                              : 'Don\'t have an account? ',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isSignUpMode = !_isSignUpMode;
                            });
                          },
                          child: Text(
                            _isSignUpMode ? 'Login' : 'Sign Up',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: const Color(0xFFFBBC04),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
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