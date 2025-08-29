import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../widgets/custom_button.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen>
    with TickerProviderStateMixin {
  bool _isOnline = false;
  bool _hasActiveRide = false;
  
  late AnimationController _statusAnimationController;
  late AnimationController _mapAnimationController;
  late Animation<double> _statusAnimation;
  late Animation<double> _mapAnimation;
  
  // Mock data
  final Map<String, dynamic> _todayStats = {
    'earnings': '₹1,250',
    'trips': 8,
    'hours': '6.5',
    'rating': 4.8,
  };
  
  final List<Map<String, dynamic>> _recentRides = [
    {
      'id': 'R001',
      'passenger': 'Rajesh Kumar',
      'pickup': 'Koraput Bus Stand',
      'destination': 'Medical College',
      'fare': '₹120',
      'time': '2:30 PM',
      'rating': 5,
    },
    {
      'id': 'R002',
      'passenger': 'Priya Sharma',
      'pickup': 'Railway Station',
      'destination': 'Market Complex',
      'fare': '₹80',
      'time': '1:15 PM',
      'rating': 4,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _statusAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _mapAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _statusAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _statusAnimationController,
      curve: Curves.elasticOut,
    ));

    _mapAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mapAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _mapAnimationController.forward();
  }

  @override
  void dispose() {
    _statusAnimationController.dispose();
    _mapAnimationController.dispose();
    super.dispose();
  }

  void _toggleOnlineStatus() {
    setState(() {
      _isOnline = !_isOnline;
    });
    
    if (_isOnline) {
      _statusAnimationController.forward();
    } else {
      _statusAnimationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          // Map Area
          _buildMapArea(),
          
          // Top Status Bar
          _buildTopStatusBar(),
          
          // Bottom Panel
          _buildBottomPanel(),
          
          // Online/Offline Toggle
          _buildOnlineToggle(),
        ],
      ),
    );
  }

  Widget _buildMapArea() {
    return AnimatedBuilder(
      animation: _mapAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _mapAnimation.value,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _isOnline 
                      ? AppTheme.successColor.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  AppTheme.backgroundColor,
                ],
              ),
            ),
            child: Stack(
              children: [
                // Placeholder for Google Maps
                Center(
                  child: Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.map_outlined,
                          size: 60.sp,
                          color: _isOnline 
                              ? AppTheme.successColor 
                              : Colors.grey,
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          _isOnline ? 'You\'re Online' : 'You\'re Offline',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: _isOnline 
                                ? AppTheme.successColor 
                                : Colors.grey,
                          ),
                        ),
                        SizedBox(height: 5.h),
                        Text(
                          _isOnline 
                              ? 'Looking for ride requests...'
                              : 'Go online to receive ride requests',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppTheme.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Driver location indicator
                if (_isOnline)
                  Positioned(
                    top: 250.h,
                    left: MediaQuery.of(context).size.width / 2 - 15.w,
                    child: AnimatedBuilder(
                      animation: _statusAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _statusAnimation.value,
                          child: Container(
                            width: 30.w,
                            height: 30.w,
                            decoration: BoxDecoration(
                              color: AppTheme.successColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.successColor.withOpacity(0.3),
                                  blurRadius: 15,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.directions_car,
                              color: Colors.white,
                              size: 16.sp,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopStatusBar() {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: _isOnline 
                    ? AppTheme.successColor 
                    : Colors.grey[400],
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    _isOnline ? 'ONLINE' : 'OFFLINE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            const Spacer(),
            
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () {
                  context.push('/profile');
                },
                icon: Icon(
                  Icons.person_outline,
                  color: AppTheme.textPrimary,
                  size: 20.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.45,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25.r),
            topRight: Radius.circular(25.r),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(top: 12.h),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Today's Stats
                    _buildTodayStats(),
                    
                    SizedBox(height: 20.h),
                    
                    // Recent Rides
                    _buildRecentRides(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Summary',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        
        SizedBox(height: 16.h),
        
        Row(
          children: [
            _buildStatCard(
              'Earnings',
              _todayStats['earnings'],
              Icons.currency_rupee,
              AppTheme.successColor,
            ),
            SizedBox(width: 12.w),
            _buildStatCard(
              'Trips',
              _todayStats['trips'].toString(),
              Icons.route,
              AppTheme.primaryColor,
            ),
          ],
        ),
        
        SizedBox(height: 12.h),
        
        Row(
          children: [
            _buildStatCard(
              'Hours',
              _todayStats['hours'],
              Icons.access_time,
              AppTheme.warningColor,
            ),
            SizedBox(width: 12.w),
            _buildStatCard(
              'Rating',
              _todayStats['rating'].toString(),
              Icons.star,
              AppTheme.warningColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 20.sp,
                ),
                const Spacer(),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Text(
              title,
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

  Widget _buildRecentRides() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Recent Rides',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                context.push('/ride-history');
              },
              child: Text(
                'View All',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        
        SizedBox(height: 12.h),
        
        ...List.generate(_recentRides.length, (index) {
          final ride = _recentRides[index];
          
          return Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      ride['passenger'],
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      ride['time'],
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 8.h),
                
                Row(
                  children: [
                    Icon(
                      Icons.my_location,
                      color: AppTheme.successColor,
                      size: 14.sp,
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        ride['pickup'],
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 4.h),
                
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: AppTheme.errorColor,
                      size: 14.sp,
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        ride['destination'],
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 8.h),
                
                Row(
                  children: [
                    Text(
                      ride['fare'],
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.successColor,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: List.generate(5, (starIndex) {
                        return Icon(
                          starIndex < ride['rating']
                              ? Icons.star
                              : Icons.star_border,
                          color: AppTheme.warningColor,
                          size: 14.sp,
                        );
                      }),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildOnlineToggle() {
    return Positioned(
      right: 20.w,
      bottom: MediaQuery.of(context).size.height * 0.5,
      child: GestureDetector(
        onTap: _toggleOnlineStatus,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 70.w,
          height: 70.w,
          decoration: BoxDecoration(
            color: _isOnline ? AppTheme.successColor : Colors.grey[400],
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (_isOnline ? AppTheme.successColor : Colors.grey)
                    .withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Icon(
            _isOnline ? Icons.pause : Icons.play_arrow,
            color: Colors.white,
            size: 30.sp,
          ),
        ),
      ),
    );
  }
}