import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';

class RideHistoryScreen extends StatefulWidget {
  const RideHistoryScreen({super.key});

  @override
  State<RideHistoryScreen> createState() => _RideHistoryScreenState();
}

class _RideHistoryScreenState extends State<RideHistoryScreen> {
  final List<Map<String, dynamic>> _rideHistory = [
    {
      'id': 'R001',
      'date': '2024-01-15',
      'time': '10:30 AM',
      'pickup': 'Koraput Railway Station',
      'destination': 'Jeypore Market',
      'fare': 120,
      'status': 'completed',
      'driverName': 'Ramesh Kumar',
      'vehicleType': 'Mini',
      'rating': 4.5,
    },
    {
      'id': 'R002',
      'date': '2024-01-14',
      'time': '3:45 PM',
      'pickup': 'Government Hospital',
      'destination': 'Bus Stand',
      'fare': 80,
      'status': 'completed',
      'driverName': 'Suresh Patel',
      'vehicleType': 'Auto',
      'rating': 5.0,
    },
    {
      'id': 'R003',
      'date': '2024-01-13',
      'time': '8:15 AM',
      'pickup': 'College Square',
      'destination': 'Shopping Complex',
      'fare': 150,
      'status': 'cancelled',
      'driverName': 'Mahesh Singh',
      'vehicleType': 'Sedan',
      'rating': null,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(
            Icons.arrow_back,
            color: AppTheme.textPrimary,
          ),
        ),
        title: Text(
          'Ride History',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: _rideHistory.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: _rideHistory.length,
              itemBuilder: (context, index) {
                return _buildRideCard(_rideHistory[index]);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80.sp,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16.h),
          Text(
            'No rides yet',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Your ride history will appear here',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRideCard(Map<String, dynamic> ride) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
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
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ride #${ride['id']}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                _buildStatusChip(ride['status']),
              ],
            ),
            
            SizedBox(height: 12.h),
            
            // Date and Time
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16.sp,
                  color: AppTheme.textSecondary,
                ),
                SizedBox(width: 8.w),
                Text(
                  '${ride['date']} at ${ride['time']}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 12.h),
            
            // Route
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: const BoxDecoration(
                        color: AppTheme.successColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 2.w,
                      height: 30.h,
                      color: Colors.grey[300],
                    ),
                    Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: const BoxDecoration(
                        color: AppTheme.errorColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ride['pickup'],
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        ride['destination'],
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            // Driver and Vehicle Info
            Row(
              children: [
                Icon(
                  Icons.person,
                  size: 16.sp,
                  color: AppTheme.textSecondary,
                ),
                SizedBox(width: 8.w),
                Text(
                  ride['driverName'],
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppTheme.textSecondary,
                  ),
                ),
                SizedBox(width: 16.w),
                Icon(
                  Icons.directions_car,
                  size: 16.sp,
                  color: AppTheme.textSecondary,
                ),
                SizedBox(width: 8.w),
                Text(
                  ride['vehicleType'],
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            // Bottom Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '₹${ride['fare']}',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.successColor,
                  ),
                ),
                Row(
                  children: [
                    if (ride['rating'] != null) ...[
                      Icon(
                        Icons.star,
                        size: 16.sp,
                        color: AppTheme.warningColor,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        ride['rating'].toString(),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(width: 16.w),
                    ],
                    GestureDetector(
                      onTap: () => _showRideDetails(ride),
                      child: Text(
                        'View Details',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (status) {
      case 'completed':
        backgroundColor = AppTheme.successColor.withOpacity(0.1);
        textColor = AppTheme.successColor;
        text = 'Completed';
        break;
      case 'cancelled':
        backgroundColor = AppTheme.errorColor.withOpacity(0.1);
        textColor = AppTheme.errorColor;
        text = 'Cancelled';
        break;
      case 'ongoing':
        backgroundColor = AppTheme.warningColor.withOpacity(0.1);
        textColor = AppTheme.warningColor;
        text = 'Ongoing';
        break;
      default:
        backgroundColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey;
        text = 'Unknown';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  void _showRideDetails(Map<String, dynamic> ride) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25.r),
            topRight: Radius.circular(25.r),
          ),
        ),
        child: Column(
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
            
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ride Details',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  
                  SizedBox(height: 20.h),
                  
                  _buildDetailRow('Ride ID', ride['id']),
                  _buildDetailRow('Date', ride['date']),
                  _buildDetailRow('Time', ride['time']),
                  _buildDetailRow('Pickup', ride['pickup']),
                  _buildDetailRow('Destination', ride['destination']),
                  _buildDetailRow('Driver', ride['driverName']),
                  _buildDetailRow('Vehicle Type', ride['vehicleType']),
                  _buildDetailRow('Fare', '₹${ride['fare']}'),
                  _buildDetailRow('Status', ride['status']),
                  if (ride['rating'] != null)
                    _buildDetailRow('Rating', '${ride['rating']} ⭐'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}