import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../widgets/custom_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _onboardingData = [
    OnboardingData(
      title: 'Book Your Ride',
      description: 'Request a ride with just a few taps and get picked up by a nearby driver.',
      icon: Icons.location_on,
      color: AppTheme.primaryColor,
    ),
    OnboardingData(
      title: 'Track in Real-time',
      description: 'Track your driver\'s location in real-time and know exactly when they\'ll arrive.',
      icon: Icons.my_location,
      color: AppTheme.secondaryColor,
    ),
    OnboardingData(
      title: 'Safe & Secure',
      description: 'All drivers are verified and your payments are secure with multiple payment options.',
      icon: Icons.security,
      color: AppTheme.successColor,
    ),
    OnboardingData(
      title: 'Rate & Review',
      description: 'Rate your experience and help us maintain the quality of our service.',
      icon: Icons.star_rate,
      color: AppTheme.warningColor,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _goToLogin();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToLogin() {
    context.go('/login');
  }

  void _skip() {
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _skip,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  return _buildOnboardingPage(_onboardingData[index]);
                },
              ),
            ),

            // Page Indicator
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _onboardingData.length,
                  (index) => _buildPageIndicator(index),
                ),
              ),
            ),

            // Navigation Buttons
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Row(
                children: [
                  // Previous Button
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousPage,
                        child: Text(
                          'Previous',
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      ),
                    ),
                  
                  if (_currentPage > 0) SizedBox(width: 12.w),
                  
                  // Next/Get Started Button
                  Expanded(
                    flex: _currentPage > 0 ? 1 : 2,
                    child: CustomButton(
                      text: _currentPage == _onboardingData.length - 1
                          ? 'Get Started'
                          : 'Next',
                      onPressed: _nextPage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingData data) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  color: data.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(40.r),
                ),
                child: Icon(
                  data.icon,
                  size: 40.sp,
                  color: data.color,
                ),
              ),

              SizedBox(height: 32.h),

              // Title
              Text(
                data.title,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 12.h),

              // Description
              Text(
                data.description,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      width: _currentPage == index ? 24.w : 8.w,
      height: 8.h,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? AppTheme.primaryColor
            : AppTheme.primaryColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4.r),
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}