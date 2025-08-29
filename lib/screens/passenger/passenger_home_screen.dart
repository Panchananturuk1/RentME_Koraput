import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class PassengerHomeScreen extends StatefulWidget {
  const PassengerHomeScreen({super.key});

  @override
  State<PassengerHomeScreen> createState() => _PassengerHomeScreenState();
}

class _PassengerHomeScreenState extends State<PassengerHomeScreen>
    with TickerProviderStateMixin {
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  
  late AnimationController _mapAnimationController;
  late AnimationController _bottomSheetAnimationController;
  late Animation<double> _mapAnimation;
  late Animation<Offset> _bottomSheetAnimation;
  
  bool _isLocationSelected = false;
  String _selectedVehicleType = 'Mini';
  
  final List<Map<String, dynamic>> _vehicleTypes = [
    {
      'name': 'Mini',
      'icon': Icons.directions_car,
      'capacity': '4 seats',
      'price': '₹120',
      'time': '2 min',
      'description': 'Affordable rides',
    },
    {
      'name': 'Sedan',
      'icon': Icons.car_rental,
      'capacity': '4 seats',
      'price': '₹180',
      'time': '3 min',
      'description': 'Comfortable rides',
    },
    {
      'name': 'SUV',
      'icon': Icons.airport_shuttle,
      'capacity': '6 seats',
      'price': '₹250',
      'time': '5 min',
      'description': 'Spacious rides',
    },
    {
      'name': 'Auto',
      'icon': Icons.directions_car,
      'capacity': '3 seats',
      'price': '₹80',
      'time': '1 min',
      'description': 'Quick rides',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _mapAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _bottomSheetAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _mapAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mapAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _bottomSheetAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _bottomSheetAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _mapAnimationController.forward();
    _bottomSheetAnimationController.forward();
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _destinationController.dispose();
    _mapAnimationController.dispose();
    _bottomSheetAnimationController.dispose();
    super.dispose();
  }

  void _selectLocation() {
    setState(() {
      _isLocationSelected = true;
    });
  }

  void _bookRide() {
    context.push('/ride-booking', extra: {
      'pickup': _pickupController.text,
      'destination': _destinationController.text,
      'vehicleType': _selectedVehicleType,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          // Map Area
          _buildMapArea(),
          
          // Top App Bar
          _buildTopAppBar(),
          
          // Bottom Sheet
          _buildBottomSheet(),
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
                          Icons.map_outlined,
                          size: 60.sp,
                          color: AppTheme.primaryColor,
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          'Map Integration',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        SizedBox(height: 5.h),
                        Text(
                          'Google Maps will be integrated here',
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
                
                // Location markers
                if (_isLocationSelected) ...[
                  Positioned(
                    top: 200.h,
                    left: 100.w,
                    child: _buildLocationMarker('Pickup', Colors.green),
                  ),
                  Positioned(
                    top: 300.h,
                    right: 80.w,
                    child: _buildLocationMarker('Drop', Colors.red),
                  ),
                ],
              ],
            ),
          ),
        );
      },
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

  Widget _buildTopAppBar() {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
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
                  // Open drawer or profile
                },
                icon: Icon(
                  Icons.menu,
                  color: AppTheme.textPrimary,
                  size: 20.sp,
                ),
              ),
            ),
            
            const Spacer(),
            
            Text(
              'RentME Koraput',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
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

  Widget _buildBottomSheet() {
    return SlideTransition(
      position: _bottomSheetAnimation,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
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
                      // Location Input Section
                      _buildLocationInputs(),
                      
                      SizedBox(height: 20.h),
                      
                      // Vehicle Selection
                      if (_isLocationSelected) ...[
                        _buildVehicleSelection(),
                        SizedBox(height: 20.h),
                      ],
                      
                      // Book Ride Button
                      _buildBookRideButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationInputs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Where to?',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        
        SizedBox(height: 16.h),
        
        // Pickup Location
        CustomTextField(
          controller: _pickupController,
          hintText: 'Pickup location',
          prefixIcon: Icons.my_location,
          onTap: () {
            // Open location picker
          },
          readOnly: true,
        ),
        
        SizedBox(height: 12.h),
        
        // Destination
        CustomTextField(
          controller: _destinationController,
          hintText: 'Where are you going?',
          prefixIcon: Icons.location_on,
          onTap: () {
            // Open location picker
            _pickupController.text = 'Current Location';
            _destinationController.text = 'Koraput Market';
            _selectLocation();
          },
          readOnly: true,
        ),
        
        SizedBox(height: 16.h),
        
        // Quick Actions
        Row(
          children: [
            _buildQuickAction(Icons.home, 'Home'),
            SizedBox(width: 12.w),
            _buildQuickAction(Icons.work, 'Work'),
            SizedBox(width: 12.w),
            _buildQuickAction(Icons.star, 'Saved'),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAction(IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 20.sp,
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose a ride',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        
        SizedBox(height: 12.h),
        
        ...List.generate(_vehicleTypes.length, (index) {
          final vehicle = _vehicleTypes[index];
          final isSelected = _selectedVehicleType == vehicle['name'];
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedVehicleType = vehicle['name'];
              });
            },
            child: Container(
              margin: EdgeInsets.only(bottom: 8.h),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppTheme.primaryColor.withOpacity(0.1)
                    : Colors.grey[50],
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isSelected 
                      ? AppTheme.primaryColor 
                      : Colors.grey[200]!,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50.w,
                    height: 50.w,
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? AppTheme.primaryColor 
                          : Colors.grey[400],
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      vehicle['icon'],
                      color: Colors.white,
                      size: 24.sp,
                    ),
                  ),
                  
                  SizedBox(width: 16.w),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              vehicle['name'],
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              vehicle['time'],
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(height: 2.h),
                        
                        Text(
                          '${vehicle['capacity']} • ${vehicle['description']}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(width: 16.w),
                  
                  Text(
                    vehicle['price'],
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBookRideButton() {
    return CustomButton(
      text: _isLocationSelected ? 'Book $_selectedVehicleType' : 'Set Destination',
      onPressed: _isLocationSelected ? _bookRide : null,
      width: double.infinity,
    );
  }
}