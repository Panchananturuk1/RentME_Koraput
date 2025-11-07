import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../services/tent_service.dart';
import '../../services/car_service.dart';
import '../../services/ride_service.dart';
import '../../providers/auth_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<ServiceItem> _services = [
    ServiceItem(
      id: 'rides',
      title: 'Book a Ride',
      subtitle: 'Quick and safe rides around Koraput',
      icon: Icons.directions_car,
      color: const Color(0xFF3B82F6),
      available: true,
      rating: 4.8,
    ),
    ServiceItem(
      id: 'bikes',
      title: 'Rent a Bike',
      subtitle: 'Explore the city on two wheels',
      icon: Icons.two_wheeler,
      color: const Color(0xFF10B981),
      available: true,
      rating: 4.7,
    ),
    ServiceItem(
      id: 'cars',
      title: 'Rent a Car',
      subtitle: 'Self-drive cars for longer trips',
      icon: Icons.directions_car_filled,
      color: const Color(0xFF8B5CF6),
      available: true,
      rating: 4.9,
    ),
    ServiceItem(
      id: 'tents',
      title: 'Night Stays',
      subtitle: 'Comfortable tent accommodations',
      icon: Icons.home_work,
      color: const Color(0xFFF59E0B),
      available: true,
      rating: 4.6,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Main Content
            Expanded(
              child: _selectedIndex == 2
                  ? _buildBookingsTab()
                  : SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 20.h),
                          
                          // Welcome Section
                          _buildWelcomeSection(),
                          
                          SizedBox(height: 24.h),
                          
                          // Quick Stats
                          _buildQuickStats(),
                          
                          SizedBox(height: 24.h),
                          
                          // Services Section
                          _buildServicesSection(),
                          
                          SizedBox(height: 24.h),
                          
                          // Recent Activity
                          _buildRecentActivity(),
                          
                          SizedBox(height: 100.h), // Bottom padding for navigation
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildHeader() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Logo
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: const Color(0xFF0EA5E9),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.directions_car,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
              
              SizedBox(width: 12.w),
              
              // App Name and Location
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RentMe',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: const Color(0xFF0EA5E9),
                          size: 14.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'Koraput, Odisha',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Profile Menu
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'logout') {
                    await authProvider.signOut();
                    if (mounted) {
                      Navigator.of(context).pushReplacementNamed('/login');
                    }
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(Icons.person_outline, size: 18.sp),
                        SizedBox(width: 8.w),
                        const Text('Profile'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'settings',
                    child: Row(
                      children: [
                        Icon(Icons.settings_outlined, size: 18.sp),
                        SizedBox(width: 8.w),
                        const Text('Settings'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, size: 18.sp, color: Colors.red),
                        SizedBox(width: 8.w),
                        const Text('Sign Out', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                child: Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Icon(
                    Icons.person,
                    color: const Color(0xFF6B7280),
                    size: 20.sp,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWelcomeSection() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0EA5E9),
                Color(0xFF0284C7),
              ],
            ),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back,',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                authProvider.userDisplayName,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Choose from our range of services to get started',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard('4', 'Services\nAvailable', Icons.apps),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildStatCard('24/7', 'Support', Icons.support_agent),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildStatCard('0', 'Total\nBookings', Icons.receipt_long),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildStatCard('New', 'Member', Icons.star),
        ),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: const Color(0xFF0EA5E9),
            size: 20.sp,
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2937),
            ),
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
      ),
    );
  }

  Widget _buildServicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Our Services',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1F2937),
          ),
        ),
        SizedBox(height: 16.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 0.85,
          ),
          itemCount: _services.length,
          itemBuilder: (context, index) {
            return _buildServiceCard(_services[index]);
          },
        ),
      ],
    );
  }

  Widget _buildServiceCard(ServiceItem service) {
    return InkWell(
      onTap: () {
        if (!service.available) return;
        if (service.id == 'tents') {
          Navigator.of(context).pushNamed('/camping');
        } else if (service.id == 'cars') {
          Navigator.of(context).pushNamed('/cars');
        } else if (service.id == 'rides') {
          Navigator.of(context).pushNamed('/ride');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${service.title} coming soon')),
          );
        }
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: service.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    service.icon,
                    color: service.color,
                    size: 24.sp,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: service.available
                        ? const Color(0xFFDCFCE7)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    service.available ? 'Available' : 'Coming Soon',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                      color: service.available
                          ? const Color(0xFF16A34A)
                          : const Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              service.title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1F2937),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              service.subtitle,
              style: TextStyle(
                fontSize: 12.sp,
                color: const Color(0xFF6B7280),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: const Color(0xFFFBBF24),
                      size: 14.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      service.rating.toString(),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: const Color(0xFF9CA3AF),
                  size: 14.sp,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingsTab() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (!auth.isLoggedIn) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline, size: 48, color: Color(0xFF9CA3AF)),
                  SizedBox(height: 12.h),
                  const Text('Sign in to view your bookings'),
                  SizedBox(height: 12.h),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pushNamed('/login'),
                    child: const Text('Go to Login'),
                  ),
                ],
              ),
            );
          }

          return FutureBuilder<List<Map<String, dynamic>>>(
            future: TentService.fetchUserBookings(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final bookings = snapshot.data ?? [];
              if (bookings.isEmpty) {
                return Center(child: const Text('No bookings yet'));
              }
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ride Bookings', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1F2937))),
                    SizedBox(height: 8.h),
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: RideService.fetchUserBookings(),
                      builder: (context, rideSnap) {
                        if (rideSnap.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (rideSnap.hasError) {
                          return Center(child: Text('Error: ${rideSnap.error}'));
                        }
                        final rides = rideSnap.data ?? [];
                        if (rides.isEmpty) {
                          return const Text('No ride bookings');
                        }
                        return Column(
                          children: rides.map((b) {
                            final pickup = b['pickup_location']?.toString() ?? 'Pickup';
                            final drop = b['dropoff_location']?.toString() ?? 'Drop-off';
                            final time = DateTime.tryParse(b['pickup_time']?.toString() ?? '');
                            final seats = b['seats']?.toString() ?? '1';
                            final fare = (b['fare_estimate'] as num?)?.toDouble();
                            final status = b['status']?.toString() ?? 'pending';
                            return Container(
                              margin: EdgeInsets.only(bottom: 12.h),
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.r),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2)),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Icon(Icons.local_taxi, size: 18.sp, color: const Color(0xFF3B82F6)),
                                    SizedBox(width: 8.w),
                                    Expanded(child: Text('$pickup → $drop', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)))
                                  ]),
                                  SizedBox(height: 6.h),
                                  Row(children: [
                                    Icon(Icons.schedule, size: 16.sp, color: const Color(0xFF6B7280)),
                                    SizedBox(width: 6.w),
                                    Text(time != null ? time!.toLocal().toString() : '—', style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280)))
                                  ]),
                                  SizedBox(height: 6.h),
                                  Row(children: [
                                    Icon(Icons.event_seat, size: 16.sp, color: const Color(0xFF6B7280)),
                                    SizedBox(width: 6.w),
                                    Text('Seats: $seats${fare != null ? ' • ₹${fare.toStringAsFixed(2)}' : ''}', style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280)))
                                  ]),
                                  SizedBox(height: 8.h),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                    decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(8.r)),
                                    child: Text(status.toUpperCase(), style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600)),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),

                    SizedBox(height: 16.h),
                    Text('Car Rentals', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1F2937))),
                    SizedBox(height: 8.h),
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: CarService.fetchUserRentals(),
                      builder: (context, carSnap) {
                        if (carSnap.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (carSnap.hasError) {
                          return Center(child: Text('Error: ${carSnap.error}'));
                        }
                        final cars = carSnap.data ?? [];
                        if (cars.isEmpty) {
                          return const Text('No car rentals');
                        }
                        return Column(
                          children: cars.map((b) {
                            final car = b['cars'] as Map<String, dynamic>?;
                            final carName = car != null ? [car['brand']?.toString(), car['model']?.toString()].whereType<String>().where((s) => s.isNotEmpty).join(' ') : 'Car';
                            final start = DateTime.tryParse(b['start_date']?.toString() ?? '');
                            final end = DateTime.tryParse(b['end_date']?.toString() ?? '');
                            final days = b['days']?.toString() ?? '0';
                            final qty = b['quantity']?.toString() ?? '1';
                            final total = (b['total_price'] as num?)?.toDouble() ?? 0;
                            final status = b['status']?.toString() ?? 'pending';
                            return Container(
                              margin: EdgeInsets.only(bottom: 12.h),
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.r),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2)),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Icon(Icons.directions_car, size: 18.sp, color: const Color(0xFF8B5CF6)),
                                    SizedBox(width: 8.w),
                                    Expanded(child: Text(carName.isNotEmpty ? carName : 'Car', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)))
                                  ]),
                                  SizedBox(height: 6.h),
                                  Row(children: [
                                    Icon(Icons.calendar_today, size: 16.sp, color: const Color(0xFF6B7280)),
                                    SizedBox(width: 6.w),
                                    Text('${start != null ? start.toIso8601String().substring(0, 10) : '?'} → ${end != null ? end.toIso8601String().substring(0, 10) : '?'}', style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280)))
                                  ]),
                                  SizedBox(height: 6.h),
                                  Row(children: [
                                    Icon(Icons.format_list_numbered, size: 16.sp, color: const Color(0xFF6B7280)),
                                    SizedBox(width: 6.w),
                                    Text('Days: $days • Qty: $qty', style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280)))
                                  ]),
                                  SizedBox(height: 6.h),
                                  Row(children: [
                                    Icon(Icons.payments, size: 16.sp, color: const Color(0xFF6B7280)),
                                    SizedBox(width: 6.w),
                                    Text('₹${total.toStringAsFixed(2)}', style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280)))
                                  ]),
                                  SizedBox(height: 8.h),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                    decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(8.r)),
                                    child: Text(status.toUpperCase(), style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600)),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),

                    SizedBox(height: 16.h),
                    Text('Tent Stays', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1F2937))),
                    SizedBox(height: 8.h),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: bookings.length,
                      separatorBuilder: (_, __) => SizedBox(height: 12.h),
                      itemBuilder: (context, i) {
                        final b = bookings[i];
                        final tent = b['tents'] as Map<String, dynamic>?;
                        final tentName = tent != null ? tent['name']?.toString() ?? 'Tent' : 'Tent';
                        final start = DateTime.tryParse(b['start_date'].toString());
                        final end = DateTime.tryParse(b['end_date'].toString());
                        final nights = b['nights']?.toString() ?? '0';
                        final qty = b['quantity']?.toString() ?? '1';
                        final total = (b['total_price'] as num?)?.toDouble() ?? 0;
                        final status = b['status']?.toString() ?? 'pending';
                        return Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    tentName,
                                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3F4F6),
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: Text(status),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                '${start != null ? start.toIso8601String().substring(0,10) : '?'} → ${end != null ? end.toIso8601String().substring(0,10) : '?'}',
                                style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280)),
                              ),
                              SizedBox(height: 8.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Nights: $nights · Qty: $qty'),
                                  Text('₹${total.toStringAsFixed(2)}'),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1F2937),
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Icon(
                      Icons.check_circle,
                      color: const Color(0xFF16A34A),
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome to RentMe!',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        Text(
                          'Account created successfully',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Just now',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF0EA5E9),
        unselectedItemColor: const Color(0xFF9CA3AF),
        selectedFontSize: 12.sp,
        unselectedFontSize: 12.sp,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class ServiceItem {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool available;
  final double rating;

  ServiceItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.available,
    required this.rating,
  });
}