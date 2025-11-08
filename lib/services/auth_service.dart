import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../config/supabase_config.dart';

class AuthService {
  static final SupabaseClient _client = SupabaseConfig.client;
  static final GoTrueClient _auth = SupabaseConfig.auth;
  static const String _envBaseUrl = String.fromEnvironment('APP_BASE_URL', defaultValue: '');

  // Get current user
  static User? get currentUser => _auth.currentUser;

  // Check if user is logged in
  static bool get isLoggedIn => currentUser != null;

  // Sign up with email and password
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  }) async {
    try {
      final response = await _auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          if (phoneNumber != null) 'phone_number': phoneNumber,
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with email and password
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Reset password
  static Future<void> resetPassword(String email) async {
    try {
      final redirectUrl = _computePasswordResetRedirectUrl();
      await _auth.resetPasswordForEmail(
        email,
        redirectTo: redirectUrl,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Update password
  static Future<UserResponse> updatePassword(String newPassword) async {
    try {
      final response = await _auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Verify OTP and update password (for code-based reset)
  static Future<AuthResponse> verifyOtpAndUpdatePassword({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    try {
      // First verify the OTP
      final response = await _auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.recovery,
      );
      
      if (response.user != null) {
        // If verification successful, update the password
        await _auth.updateUser(
          UserAttributes(password: newPassword),
        );
      }
      
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Simplified password reset for authenticated users
  static Future<bool> updatePasswordForAuthenticatedUser(String newPassword) async {
    try {
      print('🔄 Updating password for authenticated user...');
      print('Current user: ${currentUser?.email}');
      
      if (currentUser == null) {
        print('❌ No authenticated user found');
        return false;
      }
      
      final updateResponse = await _auth.updateUser(
        UserAttributes(password: newPassword),
      );
      
      print('✅ Password update successful: ${updateResponse.user != null}');
      return updateResponse.user != null;
    } catch (e) {
      print('💥 Error updating password: $e');
      throw e;
    }
  }

  // Verify recovery code and update password (for password reset links)
  static Future<bool> verifyCodeAndUpdatePassword({
    required String code,
    required String newPassword,
  }) async {
    try {
      print('🔄 Attempting to verify recovery code...');
      print('Code: $code');
      
      // Verify the recovery code (this doesn't require PKCE)
      final response = await _auth.verifyOTP(
        token: code,
        type: OtpType.recovery,
      );
      
      print('📋 Verify response received');
      print('Session exists: ${response.session != null}');
      
      if (response.session != null) {
        print('✅ Code verified, updating password...');
        
        // If verification successful, update the password
        final updateResponse = await _auth.updateUser(
          UserAttributes(password: newPassword),
        );
        
        print('Password update response: ${updateResponse.user != null}');
        return updateResponse.user != null;
      } else {
        print('❌ Failed to verify recovery code');
        return false;
      }
    } catch (e) {
      print('💥 Error in verifyCodeAndUpdatePassword: $e');
      rethrow;
    }
  }

  // Listen to auth state changes
  static Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;

  // Determine environment-aware redirect URL for password reset
  static String _computePasswordResetRedirectUrl() {
    // Prefer environment-provided base URL if set
    if (_envBaseUrl.isNotEmpty) {
      return _envBaseUrl;
    }
    // On web:
    // Use the current origin on web for both release and debug so redirects
    // work on any deployed URL (Vercel preview/prod) and localhost.
    if (kIsWeb) {
      return Uri.base.origin;
    }

    // Fallbacks for non-web targets
    // Prefer localhost during development; set production base URL if needed.
    if (kReleaseMode) {
      // If you deploy to mobile/desktop with a custom domain, set it here.
      return Uri.base.origin;
    }

    // Default localhost during development (match your setup)
    return 'http://localhost:3002';
  }

  // Get user profile data
  static Map<String, dynamic>? get userMetadata => currentUser?.userMetadata;

  // Update user profile
  static Future<UserResponse> updateProfile({
    String? fullName,
    String? phoneNumber,
  }) async {
    try {
      final response = await _auth.updateUser(
        UserAttributes(
          data: {
            if (fullName != null) 'full_name': fullName,
            if (phoneNumber != null) 'phone_number': phoneNumber,
          },
        ),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Check if email is verified
  static bool get isEmailVerified => currentUser?.emailConfirmedAt != null;

  // Resend email verification
  static Future<void> resendEmailVerification() async {
    try {
      if (currentUser?.email != null) {
        await _auth.resend(
          type: OtpType.signup,
          email: currentUser!.email!,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  // Set session with refresh token
  static Future<AuthResponse> setSession({
    required String refreshToken,
  }) async {
    try {
      final response = await _auth.setSession(refreshToken);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}