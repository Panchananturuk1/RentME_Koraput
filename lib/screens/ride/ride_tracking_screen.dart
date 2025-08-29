import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../widgets/custom_button.dart';

class RideTrackingScreen extends StatefulWidget {
  final Map<String, dynamic> rideData;
  final Map<String, dynamic> driverData;

  const RideTrackingScreen({
    super.key,
    required this.rideData,
    required this.driverData,
  });

  @override
  State<RideTrackingScreen> createState() => _RideTrackingScreenState();
}

class _RideTrackingScreenState extends State<RideTrackingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseAnimationController;
  late AnimationController _progressAnimationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;
  
  String _rideStatus = 'driver_coming'; // driver_coming, arrived, started, completed
  double _progress = 0.0;
  String _estimatedTime = '3 min';
  String _currentLocation = 'Driver is on the way';
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _simulateRideProgress();
  }

  void _initializeAnimations() {
    _pulseAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _progressAnimationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _pulseAnimationController,
      curve: Curves.easeInOut,
    ));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseAnimationController.dispose();
    _progressAnimationController.dispose();
    super.dispose();
  }

  void _simulateRideProgress() {
    // Simulate driver arriving
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted) {
        setState(() {
          _rideStatus = 'arrived';
          _currentLocation = 'Driver has arrived at pickup location';
          _estimatedTime = 'Arrived';
          _progress = 0.25;
        });
        _progressAnimationController.forward();
      }
    });

    // Simulate ride started
    Future.delayed(const Duration(seconds: 15), () {
      if (mounted) {
        setState(() {
          _rideStatus = 'started';
          _currentLocation = 'Ride in progress to destination';
          _estimatedTime = '12 min';
          _progress = 0.5;
        });
        _progressAnimationController.reset();
        _progressAnimationController.forward();
      }
    });

    // Simulate ride completion
    Future.delayed(const Duration(seconds: 25), () {
      if (mounted) {
        setState(() {
          _rideStatus = 'completed';
          _currentLocation = 'You have reached your destination';
          _estimatedTime = 'Completed';
          _progress = 1.0;
        });
        _progressAnimationController.reset();
        _progressAnimationController.forward();
        
        // Navigate to rating screen
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            context.pushReplacement('/rate-ride', extra: {
              'rideData': widget.rideData,
              'driverData': widget.driverData,
            });
          }
        });
      }
    });
  }

  void _callDriver() {
    // Implement call functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling ${widget.driverData['name']}...'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _messageDriver() {
    // Implement messaging functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening chat with driver...'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _shareLocation() {
    // Implement location sharing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Location shared successfully!'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _cancelRide() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Ride'),
        content: const Text(
          'Are you sure you want to cancel this ride? Cancellation charges may apply.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pushReplacement('/passenger-home');
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
      body: Stack(
        children: [
          // Map Area
          _buildMapArea(),
          
          // Top Status Bar
          _buildTopStatusBar(),
          
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
                  Icon(
                    Icons.map,
                    size: 60.sp,
                    color: AppTheme.primaryColor,
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    'Live Tracking Map',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    'Real-time location updates',
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
          
          // Driver location with pulse animation
          Positioned(
            top: 200.h,
            left: 100.w,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 50.w,
                    height: 50.w,
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
                      size: 24.sp,
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Route line
          Positioned(
            top: 175.h,
            left: 75.w,
            child: Container(
              width: 2.w,
              height: 100.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withOpacity(0.3),
                  ],
                ),
              ),
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

  Widget _buildTopStatusBar() {
    return SafeArea(
      child: Container(
        margin: EdgeInsets.all(16.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: _getStatusColor(),
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getStatusText(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    _currentLocation,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              _estimatedTime,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
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
          maxHeight: MediaQuery.of(context).size.height * 0.4,
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
            
            // Progress indicator
            Container(
              margin: EdgeInsets.all(20.w),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ride Progress',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        '${(_progress * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return LinearProgressIndicator(
                        value: _progress * _progressAnimation.value,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryColor,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    _buildDriverInfo(),
                    SizedBox(height: 16.h),
                    _buildActionButtons(),
                    SizedBox(height: 16.h),
                    _buildRideDetails(),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverInfo() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25.r,
            backgroundColor: AppTheme.primaryColor,
            child: Text(
              widget.driverData['name'][0],
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          
          SizedBox(width: 12.w),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.driverData['name'],
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                
                SizedBox(height: 2.h),
                
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: AppTheme.warningColor,
                      size: 14.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      widget.driverData['rating'].toString(),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 2.h),
                
                Text(
                  '${widget.driverData['vehicleModel']} • ${widget.driverData['vehicleNumber']}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          Column(
            children: [
              IconButton(
                onPressed: _callDriver,
                icon: Icon(
                  Icons.phone,
                  color: AppTheme.successColor,
                  size: 24.sp,
                ),
              ),
              IconButton(
                onPressed: _messageDriver,
                icon: Icon(
                  Icons.message,
                  color: AppTheme.primaryColor,
                  size: 24.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'Share Location',
            onPressed: _shareLocation,
            backgroundColor: Colors.grey[100],
            textColor: AppTheme.textPrimary,
            icon: Icons.share_location,
          ),
        ),
        SizedBox(width: 12.w),
        if (_rideStatus == 'driver_coming')
          Expanded(
            child: CustomButton(
              text: 'Cancel Ride',
              onPressed: _cancelRide,
              backgroundColor: AppTheme.errorColor.withOpacity(0.1),
              textColor: AppTheme.errorColor,
            ),
          ),
      ],
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Fare: ₹120',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.successColor,
                ),
              ),
              Text(
                'Distance: 5.2 km',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getStatusText() {
    switch (_rideStatus) {
      case 'driver_coming':
        return 'Driver is coming';
      case 'arrived':
        return 'Driver has arrived';
      case 'started':
        return 'Ride in progress';
      case 'completed':
        return 'Ride completed';
      default:
        return 'Unknown status';
    }
  }

  Color _getStatusColor() {
    switch (_rideStatus) {
      case 'driver_coming':
        return AppTheme.warningColor;
      case 'arrived':
        return AppTheme.primaryColor;
      case 'started':
        return AppTheme.successColor;
      case 'completed':
        return AppTheme.successColor;
      default:
        return Colors.grey;
    }
  }
}