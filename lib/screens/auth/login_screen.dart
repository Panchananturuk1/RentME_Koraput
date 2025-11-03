import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:form_validator/form_validator.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final success = await authProvider.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (success && mounted) {
        Navigator.of(context).pushReplacementNamed('/dashboard');
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
              Color(0xFFF0F9FF),
              Color(0xFFE0F2FE),
              Color(0xFFBAE6FD),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
                SizedBox(height: 40.h),
                
                // Header with Logo
                _buildHeader(),
                
                SizedBox(height: 40.h),
                
                // Login Form Card
                Container(
                  width: double.infinity,
                  constraints: BoxConstraints(maxWidth: 400.w),
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: _buildLoginForm(),
                ),
                
                SizedBox(height: 24.h),
                
                // Services Preview
                _buildServicesPreview(),
                
                SizedBox(height: 40.h),
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
        // Service Icons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildServiceIcon(Icons.directions_car, const Color(0xFF0EA5E9)),
            SizedBox(width: 16.w),
            _buildServiceIcon(Icons.two_wheeler, const Color(0xFF0EA5E9)),
            SizedBox(width: 16.w),
            _buildServiceIcon(Icons.home_work, const Color(0xFF0EA5E9)),
          ],
        ),
        
        SizedBox(height: 24.h),
        
        // App Title
        Text(
          'Welcome Back',
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1F2937),
          ),
        ),
        
        SizedBox(height: 8.h),
        
        Text(
          'Sign in to access your RentMe account',
          style: TextStyle(
            fontSize: 16.sp,
            color: const Color(0xFF6B7280),
          ),
          textAlign: TextAlign.center,
        ),
        
        SizedBox(height: 8.h),
        
        // Location
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_on,
              color: const Color(0xFF0EA5E9),
              size: 16.sp,
            ),
            SizedBox(width: 4.w),
            Text(
              'Koraput, Odisha',
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF0EA5E9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildServiceIcon(IconData icon, Color color) {
    return Container(
      width: 50.w,
      height: 50.w,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 24.sp,
      ),
    );
  }

  Widget _buildLoginForm() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sign In',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
              ),
              
              SizedBox(height: 24.h),
              
              // Error Message
              if (authProvider.errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  margin: EdgeInsets.only(bottom: 16.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: const Color(0xFFDC2626),
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          authProvider.errorMessage!,
                          style: TextStyle(
                            color: const Color(0xFFDC2626),
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              
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
                validator: ValidationBuilder().email().maxLength(50).build(),
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: const Color(0xFF9CA3AF),
                    size: 20.sp,
                  ),
                ),
              ),
              
              SizedBox(height: 20.h),
              
              // Password Field
              Text(
                'Password',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF374151),
                ),
              ),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                validator: ValidationBuilder().minLength(6).build(),
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: const Color(0xFF9CA3AF),
                    size: 20.sp,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: const Color(0xFF9CA3AF),
                      size: 20.sp,
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: 16.h),
              
              // Remember Me & Forgot Password
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: Checkbox(
                          value: _rememberMe,
                          onChanged: (value) {
                            setState(() {
                              _rememberMe = value ?? false;
                            });
                          },
                          activeColor: const Color(0xFF0EA5E9),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Remember me',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      print('Forgot Password button pressed'); // Debug print
                      Navigator.of(context).pushNamed('/forgot-password');
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF0EA5E9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 24.h),
              
              // Login Button
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: authProvider.isLoading ? null : _handleLogin,
                  child: authProvider.isLoading
                      ? SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              
              SizedBox(height: 24.h),
              
              // Sign Up Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/signup');
                    },
                    child: Text(
                      'Create one here',
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
        );
      },
    );
  }

  Widget _buildServicesPreview() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text(
            'Available Services',
            style: TextStyle(
              fontSize: 12.sp,
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildServiceItem(Icons.directions_car, 'Rides & Cars'),
              _buildServiceItem(Icons.two_wheeler, 'Bike Rentals'),
              _buildServiceItem(Icons.home_work, 'Night Stays'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(IconData icon, String label) {
    return Column(
      children: [
        Icon(
          icon,
          color: const Color(0xFF0EA5E9),
          size: 24.sp,
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: const Color(0xFF6B7280),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}