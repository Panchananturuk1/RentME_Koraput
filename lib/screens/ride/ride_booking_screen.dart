import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../widgets/custom_button.dart';

class RideBookingScreen extends StatefulWidget {
  final Map<String, dynamic> rideData;

  const RideBookingScreen({
    super.key,
    required this.rideData,
  });

  @override
  State<RideBookingScreen> createState() => _RideBookingScreenState();
}

class _RideBookingScreenState extends State<RideBookingScreen>
    with TickerProviderStateMixin {
  late AnimationController _searchAnimationController;
  late AnimationController _driverFoundAnimationController;
  late Animation<double> _searchAnimation;
  late Animation<double> _driverFoundAnimation;
  
  bool _isSearchingDriver = false;
  bool _driverFound = false;
  bool _rideConfirmed = false;
  
  // Mock driver data
  final Map<String, dynamic> _driverData = {
    'name': 'Ramesh Kumar',
    'rating': 4.8,
    'vehicleNumber': 'OD 05 AB 1234',
    'vehicleModel': 'Maruti Swift',
    'vehicleColor': 'White',
    'phoneNumber': '+91 9876543210',
    'profileImage': 'https://via.placeholder.com/150',
    'eta': '3 min',
    'distance': '0.8 km',
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startDriverSearch();
  }

  void _initializeAnimations() {
    _searchAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _driverFoundAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _searchAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _searchAnimationController,
      curve: Curves.easeInOut,
    ));

    _driverFoundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _driverFoundAnimationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _searchAnimationController.dispose();
    _driverFoundAnimationController.dispose();
    super.dispose();
  }

  void _startDriverSearch() {
    setState(() {
      _isSearchingDriver = true;
    });
    
    _searchAnimationController.repeat();
    
    // Simulate driver search
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _isSearchingDriver = false;
          _driverFound = true;
        });
        
        _searchAnimationController.stop();
        _driverFoundAnimationController.forward();
      }
    });
  }

  void _confirmRide() {
    setState(() {
      _rideConfirmed = true;
    });
    
    // Navigate to ride tracking screen
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        context.pushReplacement('/ride-tracking', extra: {
          'rideData': widget.rideData,
          'driverData': _driverData,
        });
      }
    });
  }

  void _cancelBooking() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
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
          onPressed: _cancelBooking,
          icon: const Icon(
            Icons.close,
            color: AppTheme.textPrimary,
          ),
        ),
        title: Text(
          'Book Ride',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Map Area
          _buildMapArea(),
          
          // Bottom Content
          _buildBottomContent(),
        ],
      ),
    );
  }

  Widget _buildMapArea() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.primaryColor.withOpacity(0.1),
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
                  if (_isSearchingDriver) ...[
                    AnimatedBuilder(
                      animation: _searchAnimation,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _searchAnimation.value * 2 * 3.14159,
                          child: Icon(
                            Icons.search,
                            size: 60.sp,
                            color: AppTheme.primaryColor,
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'Finding Driver...',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ] else if (_driverFound) ...[
                    AnimatedBuilder(
                      animation: _driverFoundAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _driverFoundAnimation.value,
                          child: Icon(
                            Icons.check_circle,
                            size: 60.sp,
                            color: AppTheme.successColor,
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'Driver Found!',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.successColor,
                      ),
                    ),
                  ],
                  SizedBox(height: 5.h),
                  Text(
                    'Route will be displayed here',
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
          
          // Route markers
          Positioned(
            top: 150.h,
            left: 50.w,
            child: _buildLocationMarker('Pickup', AppTheme.successColor),
          ),
          Positioned(
            bottom: 200.h,
            right: 50.w,
            child: _buildLocationMarker('Drop', AppTheme.errorColor),
          ),
          
          // Driver location (when found)
          if (_driverFound)
            Positioned(
              top: 200.h,
              left: 100.w,
              child: AnimatedBuilder(
                animation: _driverFoundAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _driverFoundAnimation.value,
                    child: Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.directions_car,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLocationMarker(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildBottomContent() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.5,
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
                    if (_isSearchingDriver) ...[
                      _buildSearchingContent(),
                    ] else if (_driverFound) ...[
                      _buildDriverFoundContent(),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchingContent() {
    return Column(
      children: [
        Text(
          'Looking for nearby drivers...',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        
        SizedBox(height: 16.h),
        
        _buildRideDetails(),
        
        SizedBox(height: 20.h),
        
        LinearProgressIndicator(
          backgroundColor: Colors.grey[200],
          valueColor: const AlwaysStoppedAnimation<Color>(
            AppTheme.primaryColor,
          ),
        ),
        
        SizedBox(height: 16.h),
        
        Text(
          'This usually takes 1-2 minutes',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppTheme.textSecondary,
          ),
        ),
        
        SizedBox(height: 20.h),
        
        CustomButton(
          text: 'Cancel Search',
          onPressed: _cancelBooking,
          width: double.infinity,
          backgroundColor: Colors.grey[300],
          textColor: AppTheme.textPrimary,
        ),
      ],
    );
  }

  Widget _buildDriverFoundContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Driver Found!',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.successColor,
          ),
        ),
        
        SizedBox(height: 16.h),
        
        _buildDriverInfo(),
        
        SizedBox(height: 20.h),
        
        _buildRideDetails(),
        
        SizedBox(height: 20.h),
        
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'Cancel',
                onPressed: _cancelBooking,
                backgroundColor: Colors.grey[300],
                textColor: AppTheme.textPrimary,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              flex: 2,
              child: CustomButton(
                text: _rideConfirmed ? 'Confirmed!' : 'Confirm Ride',
                onPressed: _rideConfirmed ? null : _confirmRide,
                isLoading: _rideConfirmed,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDriverInfo() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.successColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppTheme.successColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30.r,
            backgroundColor: AppTheme.primaryColor,
            child: Text(
              _driverData['name'][0],
              style: TextStyle(
                fontSize: 24.sp,
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
                  _driverData['name'],
                  style: TextStyle(
                    fontSize: 18.sp,
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
                      _driverData['rating'].toString(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Text(
                      '${_driverData['vehicleModel']} • ${_driverData['vehicleColor']}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 4.h),
                
                Text(
                  _driverData['vehicleNumber'],
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          
          Column(
            children: [
              Text(
                _driverData['eta'],
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.successColor,
                ),
              ),
              Text(
                'away',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRideDetails() {
    return Container(
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
          Text(
            'Ride Details',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          
          SizedBox(height: 12.h),
          
          Row(
            children: [
              Icon(
                Icons.my_location,
                color: AppTheme.successColor,
                size: 16.sp,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  widget.rideData['pickup'] ?? 'Pickup Location',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 8.h),
          
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: AppTheme.errorColor,
                size: 16.sp,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  widget.rideData['destination'] ?? 'Destination',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 12.h),
          
          Row(
            children: [
              Text(
                'Vehicle: ',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                widget.rideData['vehicleType'] ?? 'Mini',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                'Fare: ₹120',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.successColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}