class AppConfig {
  // Twilio Configuration
  // To get these values:
  // 1. Sign up at https://www.twilio.com/
  // 2. Go to Console Dashboard
  // 3. Find your Account SID and Auth Token
  // 4. Get a Twilio phone number from Phone Numbers > Manage > Buy a number
  
  static const String twilioAccountSid = String.fromEnvironment(
    'TWILIO_ACCOUNT_SID',
    defaultValue: 'YOUR_TWILIO_ACCOUNT_SID_HERE',
  );
  
  static const String twilioAuthToken = String.fromEnvironment(
    'TWILIO_AUTH_TOKEN',
    defaultValue: 'YOUR_TWILIO_AUTH_TOKEN_HERE',
  );
  
  static const String twilioPhoneNumber = String.fromEnvironment(
    'TWILIO_PHONE_NUMBER',
    defaultValue: 'YOUR_TWILIO_PHONE_NUMBER_HERE', // Format: +1234567890
  );
  
  // Supabase Configuration
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'YOUR_SUPABASE_URL_HERE',
  );
  
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'YOUR_SUPABASE_ANON_KEY_HERE',
  );
  
  // App Configuration
  static const String appName = 'RentME Koraput';
  static const String appVersion = '1.0.0';
  
  // OTP Configuration
  static const int otpLength = 6;
  static const int otpExpiryMinutes = 5;
  
  // Validation helpers
  static bool get isTwilioConfigured {
    return twilioAccountSid != 'YOUR_TWILIO_ACCOUNT_SID_HERE' &&
           twilioAuthToken != 'YOUR_TWILIO_AUTH_TOKEN_HERE' &&
           twilioPhoneNumber != 'YOUR_TWILIO_PHONE_NUMBER_HERE';
  }
  
  static bool get isSupabaseConfigured {
    return supabaseUrl != 'YOUR_SUPABASE_URL_HERE' &&
           supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY_HERE';
  }
}