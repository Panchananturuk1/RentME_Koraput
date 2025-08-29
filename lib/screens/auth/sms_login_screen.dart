import 'package:flutter/material.dart';
// Removed: import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'sms_otp_screen.dart';

class SmsLoginScreen extends StatefulWidget {
  final String userType;
  
  const SmsLoginScreen({
    Key? key,
    required this.userType,
  }) : super(key: key);

  @override
  State<SmsLoginScreen> createState() => _SmsLoginScreenState();
}

class _SmsLoginScreenState extends State<SmsLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  bool _isNewUser = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = AuthService();
      final result = await authService.sendSMSOTP(
        phoneNumber: _phoneController.text.trim(),
        userType: widget.userType,
      );

      if (result['success']) {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SmsOtpScreen(
                phoneNumber: _phoneController.text.trim(),
                userType: widget.userType,
                userName: _nameController.text.trim(),
                isNewUser: _isNewUser,
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed to send OTP'),
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

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    
    // Remove all non-digit characters
    String cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (cleaned.length < 10) {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }

  String? _validateName(String? value) {
    if (_isNewUser && (value == null || value.trim().isEmpty)) {
      return 'Please enter your name';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'SMS Login',
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                
                // Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: Icon(
                          Icons.sms,
                          size: 40,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'SMS Verification',
                        style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                           fontSize: 28,
                           fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter your phone number to receive\na verification code via SMS',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // User Type Toggle
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isNewUser = false;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !_isNewUser ? AppTheme.primaryColor : Colors.transparent,
                            border: Border.all(
                              color: AppTheme.primaryColor,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Existing User',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: !_isNewUser ? Colors.white : AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isNewUser = true;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _isNewUser ? AppTheme.primaryColor : Colors.transparent,
                            border: Border.all(
                              color: AppTheme.primaryColor,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'New User',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _isNewUser ? Colors.white : AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Name Field (for new users)
                if (_isNewUser) ...[
                  CustomTextField(
                    controller: _nameController,
                    labelText: 'Full Name',
                    hintText: 'Enter your full name',
                    prefixIcon: Icons.person,
                    validator: _validateName,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 20),
                ],
                
                // Phone Number Field
                CustomTextField(
                  controller: _phoneController,
                  labelText: 'Phone Number',
                  hintText: 'Enter your phone number',
                  prefixIcon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: _validatePhoneNumber,
                  textInputAction: TextInputAction.done,
                ),
                
                const SizedBox(height: 32),
                
                // Send OTP Button
                CustomButton(
                  text: 'Send OTP',
                  onPressed: _isLoading ? null : _sendOTP,
                  isLoading: _isLoading,
                  icon: Icons.sms,
                ),
                
                const SizedBox(height: 24),
                
                // Info Text
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
                          'You will receive a 6-digit verification code via SMS. Standard messaging rates may apply.',
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
      ),
    );
  }
}