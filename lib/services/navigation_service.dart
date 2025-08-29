import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/otp_verification_screen.dart';
import '../screens/auth/sms_login_screen.dart';
import '../screens/auth/sms_otp_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/passenger/passenger_home_screen.dart';
import '../screens/driver/driver_home_screen.dart';
import '../screens/ride/ride_booking_screen.dart';
import '../screens/ride/ride_tracking_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/ride/ride_history_screen.dart';
import '../screens/payment/payment_screen.dart';
import '../screens/rating/rating_screen.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/splash',
    routes: [
      // Splash Screen
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Onboarding
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      
      // Authentication Routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/otp-verification',
        name: 'otp-verification',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>? ?? {};
          return OTPVerificationScreen(
            data: data,
          );
        },
      ),
      
      // SMS Authentication Routes
      GoRoute(
        path: '/sms-login',
        name: 'sms-login',
        builder: (context, state) {
          final userType = state.extra as String? ?? 'passenger';
          return SmsLoginScreen(
            userType: userType,
          );
        },
      ),
      GoRoute(
        path: '/sms-otp',
        name: 'sms-otp',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>? ?? {};
          return SmsOtpScreen(
            phoneNumber: data['phoneNumber'] ?? '',
            userType: data['userType'] ?? 'passenger',
            isNewUser: data['isNewUser'] ?? false,
            userName: data['userName'],
          );
        },
      ),
      
      // Passenger Routes
      GoRoute(
        path: '/passenger-home',
        name: 'passenger-home',
        builder: (context, state) => const PassengerHomeScreen(),
      ),
      
      // Driver Routes
      GoRoute(
        path: '/driver-home',
        name: 'driver-home',
        builder: (context, state) => const DriverHomeScreen(),
      ),
      
      // Ride Routes
      GoRoute(
        path: '/ride-booking',
        name: 'ride-booking',
        builder: (context, state) {
          // Mock ride data for demonstration
          final rideData = {'pickup': 'Current Location', 'destination': 'Destination'};
          return RideBookingScreen(rideData: rideData);
        },
      ),
      GoRoute(
        path: '/ride-tracking/:rideId',
        name: 'ride-tracking',
        builder: (context, state) {
          final rideId = state.pathParameters['rideId']!;
          // Mock data for demonstration
          final rideData = {'id': rideId, 'status': 'ongoing'};
          final driverData = {'name': 'John Doe', 'rating': 4.5};
          return RideTrackingScreen(rideData: rideData, driverData: driverData);
        },
      ),
      
      // Profile Routes
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      
      // History Routes
      GoRoute(
        path: '/ride-history',
        name: 'ride-history',
        builder: (context, state) => const RideHistoryScreen(),
      ),
      
      // Payment Routes
      GoRoute(
        path: '/payment/:rideId',
        name: 'payment',
        builder: (context, state) {
          return const PaymentScreen();
        },
      ),
      
      // Rating Routes
      GoRoute(
        path: '/rating/:rideId',
        name: 'rating',
        builder: (context, state) {
          final rideId = state.pathParameters['rideId']!;
          // Mock data for demonstration
          final rideData = {'id': rideId, 'status': 'completed'};
          final driverData = {'name': 'John Doe', 'rating': 4.5, 'vehicleNumber': 'OD-05-1234'};
          return RatingScreen(rideData: rideData, driverData: driverData);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page Not Found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'The page you are looking for does not exist.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/splash'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
  
  // Navigation helper methods
  static void goToLogin() {
    router.go('/login');
  }
  
  static void goToSignup() {
    router.go('/signup');
  }
  
  static void goToPassengerHome() {
    router.go('/passenger-home');
  }
  
  static void goToDriverHome() {
    router.go('/driver-home');
  }
  
  static void goToRideBooking() {
    router.go('/ride-booking');
  }
  
  static void goToRideTracking(String rideId) {
    router.go('/ride-tracking/$rideId');
  }
  
  static void goToProfile() {
    router.go('/profile');
  }
  
  static void goToRideHistory() {
    router.go('/ride-history');
  }
  
  static void goToPayment(String rideId) {
    router.go('/payment/$rideId');
  }
  
  static void goToRating(String rideId) {
    router.go('/rating/$rideId');
  }
  
  static void goBack() {
    if (router.canPop()) {
      router.pop();
    }
  }
}