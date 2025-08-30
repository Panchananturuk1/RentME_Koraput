import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// Removed: import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../services/auth_service.dart';
import '../../services/navigation_service.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'whatsapp_otp_screen.dart';

class WhatsAppLoginScreen extends StatefulWidget {
  final String userType;
  final String? phoneNumber;

  const WhatsAppLoginScreen({
    Key? key,
    required this.userType,
    this.phoneNumber,
  }) : super(key: key);

  @override
  State<WhatsAppLoginScreen> createState() => _WhatsAppLoginScreenState();
}

class _WhatsAppLoginScreenState extends State<WhatsAppLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedCountryCode = '+91';
  bool _isWhatsAppAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkWhatsAppAvailability();
    
    // Pre-fill phone number if provided
    if (widget.phoneNumber != null && widget.phoneNumber!.isNotEmpty) {
      _phoneController.text = widget.phoneNumber!;
    }
  }

  Future<void> _checkWhatsAppAvailability() async {
    final isAvailable = await AuthService().isWhatsAppAvailable();
    setState(() {
      _isWhatsAppAvailable = isAvailable;
    });
  }

  Future<void> _loginWithWhatsApp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = AuthService();
      final isAvailable = await authService.isWhatsAppAvailable();
      if (!isAvailable) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('WhatsApp is not available on this device'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      final result = await authService.loginWithWhatsApp(
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
          // Authentication initiated, show success message
          setState(() {
            _errorMessage = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'WhatsApp authentication initiated')),
          );
        }
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Failed to initiate WhatsApp login';
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

  Future<void> _authenticateWithWhatsApp() async {
    if (!(await AuthService().isWhatsAppAvailable())) {
      setState(() {
        _errorMessage = 'WhatsApp is not available on this device';
      });
      return;
    }

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
          // Authentication initiated, show success message
          setState(() {
            _errorMessage = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'WhatsApp authentication initiated')),
          );
        }
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'WhatsApp authentication failed';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Authentication error. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  


  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
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
          'WhatsApp Login',
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
                
                // WhatsApp Logo
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFF25D366),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(
                      Icons.chat,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Title
                const Text(
                  'Login with WhatsApp',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Subtitle
                Text(
                  'Fast and secure authentication via WhatsApp',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Name Input (Optional)
                CustomTextField(
                  controller: _nameController,
                  labelText: 'Name (Optional)',
                  hintText: 'Enter your name',
                  prefixIcon: Icons.person_outline,
                ),
                
                const SizedBox(height: 16),
                
                // Phone Number Input
                Row(
                  children: [
                    // Country Code Dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCountryCode,
                          items: const [
                            DropdownMenuItem(value: '+91', child: Text('+91')),
                            DropdownMenuItem(value: '+1', child: Text('+1')),
                            DropdownMenuItem(value: '+44', child: Text('+44')),
                            DropdownMenuItem(value: '+971', child: Text('+971')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedCountryCode = value!;
                            });
                          },
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Phone Number Field
                    Expanded(
                      child: CustomTextField(
                        controller: _phoneController,
                        labelText: 'Phone Number',
                        hintText: 'Enter phone number',
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter phone number';
                          }
                          if (value.length < 10) {
                            return 'Enter valid phone number';
                          }
                          return null;
                        },
                        prefixIcon: Icons.phone_outlined,
                      ),
                    ),
                  ],
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
                
                // Send OTP Button
                CustomButton(
                  text: 'Login with WhatsApp',
                  onPressed: _isLoading ? null : _loginWithWhatsApp,
                  isLoading: _isLoading,
                ),
                
                const SizedBox(height: 16),
                
                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey[300])),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey[300])),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // One-tap WhatsApp Login
                if (_isWhatsAppAvailable)
                  CustomButton(
                    text: 'Continue with WhatsApp',
                    onPressed: _isLoading ? null : _authenticateWithWhatsApp,
                    isLoading: _isLoading,
                    backgroundColor: const Color(0xFF25D366),
                    icon: Icons.chat,
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_outlined, color: Colors.orange[600], size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'WhatsApp is not installed on this device. Please install WhatsApp or use OTP method.',
                            style: TextStyle(
                              color: Colors.orange[700],
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                const Spacer(),
                
                // Back to Email Login
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Back to Email Login',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // WhatsApp Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'WhatsApp authentication is fast, secure, and doesn\'t require passwords. Your phone number will be verified instantly.',
                          style: TextStyle(
                            color: Colors.blue[700],
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