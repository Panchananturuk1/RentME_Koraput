import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../services/auth_service.dart';
import 'whatsapp_login_screen.dart';
import 'firebase_email_login_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _whatsappController = TextEditingController();
  
  bool _isLoading = false;
  bool _isWhatsAppLoading = false;
  bool _isOTPMode = true;
  String _selectedUserType = AppConstants.userTypePassenger;
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isOTPMode) {
        // Send OTP to email
        final result = await _authService.sendOTP(
          _emailController.text,
          _selectedUserType,
        );
        
        if (result['success']) {
          _showSnackBar('OTP sent to your email!');
          // Navigate to OTP verification
          context.pushNamed(
            'otp-verification',
            extra: {
              'email': _emailController.text,
              'userType': _selectedUserType,
            },
          );
        } else {
          _showSnackBar(result['message'] ?? 'Failed to send OTP', isError: true);
        }
      } else {
        // Email/Password login
        final result = await _authService.signInWithEmail(
          email: _emailController.text,
          password: _passwordController.text,
        );
        
        if (result['success']) {
          _showSnackBar('Login successful!');
          // Navigate based on user type
          if (_selectedUserType == AppConstants.userTypePassenger) {
            context.go('/passenger-home');
          } else {
            context.go('/driver-home');
          }
        } else {
          _showSnackBar(result['message'] ?? 'Login failed', isError: true);
        }
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

  void _loginWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.signInWithGoogle();
      
      if (result['success']) {
        _showSnackBar('Google login successful!');
        // Navigate based on user type
        if (_selectedUserType == AppConstants.userTypePassenger) {
          context.go('/passenger-home');
        } else {
          context.go('/driver-home');
        }
      } else {
        _showSnackBar(result['message'] ?? 'Google login failed', isError: true);
      }
    } catch (e) {
      _showSnackBar('Google login error: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _sendWhatsAppOTP() async {
    if (_whatsappController.text.isEmpty) {
      _showSnackBar('Please enter your WhatsApp number', isError: true);
      return;
    }

    setState(() {
      _isWhatsAppLoading = true;
    });

    try {
      // Navigate to WhatsApp login screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WhatsAppLoginScreen(
            phoneNumber: _whatsappController.text,
            userType: _selectedUserType,
          ),
        ),
      );
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isWhatsAppLoading = false;
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40.h),

                // App Logo and Title
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80.w,
                        height: 80.w,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Icon(
                          Icons.local_taxi,
                          size: 40.sp,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Welcome to ${AppConstants.appName}',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Sign in to continue',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 48.h),

                // User Type Selection
                Text(
                  'I am a',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildUserTypeCard(
                        AppConstants.userTypePassenger,
                        'Passenger',
                        Icons.person,
                        'Book rides',
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildUserTypeCard(
                        AppConstants.userTypeDriver,
                        'Driver',
                        Icons.drive_eta,
                        'Earn money',
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 32.h),

                // WhatsApp OTP Section
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: const Color(0xFF25D366), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.chat,
                            color: const Color(0xFF25D366),
                            size: 20.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Login with WhatsApp OTP',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF25D366),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      CustomTextField(
                        controller: _whatsappController,
                        hintText: 'Enter WhatsApp number',
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icons.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your WhatsApp number';
                          }
                          if (!RegExp(r'^[+]?[0-9]{10,15}$').hasMatch(value)) {
                            return 'Please enter a valid phone number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),
                      CustomButton(
                        text: 'Send OTP',
                        onPressed: _sendWhatsAppOTP,
                        isLoading: _isWhatsAppLoading,
                        backgroundColor: const Color(0xFF25D366),
                        textColor: Colors.white,
                        icon: Icons.send,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),

                SizedBox(height: 24.h),

                // Firebase Email Login Button
                CustomButton(
                  text: 'Login with Email (Firebase)',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FirebaseEmailLoginScreen(
                          userType: _selectedUserType,
                        ),
                      ),
                    );
                  },
                  isLoading: false,
                  isOutlined: true,
                  backgroundColor: const Color(0xFFFBBC04),
                  textColor: Colors.black,
                  icon: Icons.email,
                ),

                SizedBox(height: 32.h),

                // Sign Up Link
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account? ',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/signup'),
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                // Terms and Privacy
                Center(
                  child: Text(
                    'By continuing, you agree to our Terms of Service and Privacy Policy',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserTypeCard(String type, String title, IconData icon, String subtitle) {
    final isSelected = _selectedUserType == type;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedUserType = type;
        });
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.grey[50],
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32.sp,
              color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}