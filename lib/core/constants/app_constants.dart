class AppConstants {
  // App Information
  static const String appName = 'RentME Koraput';
  static const String appVersion = '1.0.0';
  
  // API Configuration
  static const String baseUrl = 'https://api.rentmekoraput.com';
  static const String apiVersion = '/v1';
  
  // Map Configuration
  static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
  static const double defaultLatitude = 18.8161;
  static const double defaultLongitude = 82.7103; // Koraput coordinates
  
  // Payment Configuration
  static const String razorpayKeyId = 'YOUR_RAZORPAY_KEY_ID';
  
  // Firebase Configuration
  static const String firebaseProjectId = 'rentme-koraput';
  
  // App Settings
  static const int splashDuration = 3000; // milliseconds
  static const int otpTimeout = 60; // seconds
  static const double defaultZoom = 15.0;
  
  // Ride Configuration
  static const double baseFare = 25.0;
  static const double perKmRate = 12.0;
  static const double perMinuteRate = 2.0;
  static const double surgePriceMultiplier = 1.5;
  
  // User Types
  static const String userTypePassenger = 'passenger';
  static const String userTypeDriver = 'driver';
  
  // Ride Status
  static const String rideStatusRequested = 'requested';
  static const String rideStatusAccepted = 'accepted';
  static const String rideStatusStarted = 'started';
  static const String rideStatusCompleted = 'completed';
  static const String rideStatusCancelled = 'cancelled';
  
  // Payment Methods
  static const String paymentCash = 'cash';
  static const String paymentCard = 'card';
  static const String paymentUPI = 'upi';
  static const String paymentWallet = 'wallet';
}