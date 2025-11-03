import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class AuthService {
  static final SupabaseClient _client = SupabaseConfig.client;
  static final GoTrueClient _auth = SupabaseConfig.auth;

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
      await _auth.resetPasswordForEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  // Listen to auth state changes
  static Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;

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
}