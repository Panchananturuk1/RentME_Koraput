import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../widgets/custom_button.dart';

class RatingScreen extends StatefulWidget {
  final Map<String, dynamic> rideData;
  final Map<String, dynamic> driverData;

  const RatingScreen({
    super.key,
    required this.rideData,
    required this.driverData,
  });

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  int _rating = 0;
  final TextEditingController _feedbackController = TextEditingController();
  bool _isSubmitting = false;
  
  final List<String> _quickFeedback = [
    'Great driver!',
    'Clean vehicle',
    'On time',
    'Safe driving',
    'Friendly',
    'Professional',
  ];
  
  final List<String> _selectedFeedback = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  void _submitRating() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a rating'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thank you for your feedback!'),
          backgroundColor: AppTheme.successColor,
        ),
      );

      // Navigate to home
      context.pushReplacement('/passenger-home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  children: [
                    SizedBox(height: 40.h),
                    
                    // Success Icon
                    AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Container(
                            width: 100.w,
                            height: 100.w,
                            decoration: BoxDecoration(
                              color: AppTheme.successColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.successColor.withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 50.sp,
                            ),
                          ),
                        );
                      },
                    ),
                    
                    SizedBox(height: 30.h),
                    
                    // Title
                    Text(
                      'Trip Completed!',
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    
                    SizedBox(height: 8.h),
                    
                    Text(
                      'How was your ride experience?',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    SizedBox(height: 40.h),
                    
                    // Driver Info
                    _buildDriverInfo(),
                    
                    SizedBox(height: 30.h),
                    
                    // Rating Stars
                    _buildRatingStars(),
                    
                    SizedBox(height: 30.h),
                    
                    // Quick Feedback
                    _buildQuickFeedback(),
                    
                    SizedBox(height: 30.h),
                    
                    // Feedback Text Field
                    _buildFeedbackTextField(),
                    
                    SizedBox(height: 40.h),
                    
                    // Submit Button
                    CustomButton(
                      text: 'Submit Rating',
                      onPressed: _submitRating,
                      isLoading: _isSubmitting,
                      width: double.infinity,
                    ),
                    
                    SizedBox(height: 16.h),
                    
                    // Skip Button
                    TextButton(
                      onPressed: () => context.pushReplacement('/passenger-home'),
                      child: Text(
                        'Skip for now',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDriverInfo() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35.r,
            backgroundColor: AppTheme.primaryColor,
            child: Text(
              widget.driverData['name'][0],
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          
          SizedBox(width: 16.w),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.driverData['name'],
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                
                SizedBox(height: 4.h),
                
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: AppTheme.warningColor,
                      size: 16.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      widget.driverData['rating'].toString(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Text(
                      widget.driverData['vehicleNumber'],
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 4.h),
                
                Text(
                  '${widget.driverData['vehicleModel']} • ${widget.driverData['vehicleColor']}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingStars() {
    return Column(
      children: [
        Text(
          'Rate your driver',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        
        SizedBox(height: 16.h),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _rating = index + 1;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                child: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  color: AppTheme.warningColor,
                  size: 40.sp,
                ),
              ),
            );
          }),
        ),
        
        SizedBox(height: 8.h),
        
        if (_rating > 0)
          Text(
            _getRatingText(_rating),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.primaryColor,
            ),
          ),
      ],
    );
  }

  Widget _buildQuickFeedback() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick feedback (optional)',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        
        SizedBox(height: 12.h),
        
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: _quickFeedback.map((feedback) {
            final isSelected = _selectedFeedback.contains(feedback);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedFeedback.remove(feedback);
                  } else {
                    _selectedFeedback.add(feedback);
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppTheme.primaryColor 
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isSelected 
                        ? AppTheme.primaryColor 
                        : Colors.grey[300]!,
                  ),
                ),
                child: Text(
                  feedback,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: isSelected 
                        ? Colors.white 
                        : AppTheme.textPrimary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFeedbackTextField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional feedback',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        
        SizedBox(height: 12.h),
        
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _feedbackController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Tell us about your experience...',
              hintStyle: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14.sp,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.all(16.w),
            ),
          ),
        ),
      ],
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent';
      default:
        return '';
    }
  }
}