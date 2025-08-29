import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String supabaseUrl = 'https://irafyvdazsfqyruyfagr.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlyYWZ5dmRhenNmcXlydXlmYWdyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY0MzkxODIsImV4cCI6MjA3MjAxNTE4Mn0.3nag8aKUCLY1zqoFgyBTuiSWcH2822WeXKsHWfEySmk';

  static SupabaseClient get client => Supabase.instance.client;

  /// Initialize Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  /// Get current user
  static User? get currentUser => client.auth.currentUser;

  /// Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;

  /// Sign up with email and password
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    return await client.auth.signUp(
      email: email,
      password: password,
      data: data,
    );
  }

  /// Sign in with email and password
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign in with OTP (email)
  static Future<void> signInWithOtp({
    required String email,
  }) async {
    await client.auth.signInWithOtp(
      email: email,
    );
  }

  /// Verify OTP
  static Future<AuthResponse> verifyOtp({
    required String email,
    required String token,
    required OtpType type,
  }) async {
    return await client.auth.verifyOTP(
      email: email,
      token: token,
      type: type,
    );
  }

  /// Sign out
  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  /// Reset password
  static Future<void> resetPassword(String email) async {
    await client.auth.resetPasswordForEmail(email);
  }

  /// Update user profile
  static Future<UserResponse> updateProfile({
    Map<String, dynamic>? data,
  }) async {
    return await client.auth.updateUser(
      UserAttributes(data: data),
    );
  }

  /// Listen to auth state changes
  static Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  // Database operations
  
  /// Insert data into a table
  static Future<List<Map<String, dynamic>>> insert({
    required String table,
    required Map<String, dynamic> data,
  }) async {
    final response = await client.from(table).insert(data).select();
    return response;
  }

  /// Select data from a table
  static Future<List<Map<String, dynamic>>> select({
    required String table,
    String columns = '*',
    String? filter,
  }) async {
    var query = client.from(table).select(columns);
    
    if (filter != null && filter.isNotEmpty) {
      // very small parser for patterns like: "eq:field:value"
      try {
        final parts = filter.split(':');
        if (parts.length >= 3) {
          final op = parts[0];
          final field = parts[1];
          // value can contain ':' as well, join the rest back
          final value = parts.sublist(2).join(':');
          switch (op) {
            case 'eq':
              query = query.eq(field, value);
              break;
            case 'ilike':
              query = query.ilike(field, value);
              break;
            case 'gt':
              query = query.gt(field, value);
              break;
            case 'gte':
              query = query.gte(field, value);
              break;
            case 'lt':
              query = query.lt(field, value);
              break;
            case 'lte':
              query = query.lte(field, value);
              break;
            default:
              // unsupported operator, ignore
              break;
          }
        }
      } catch (_) {
        // ignore malformed filter
      }
    }
    
    return await query;
  }

  /// Update data in a table
  static Future<List<Map<String, dynamic>>> update({
    required String table,
    required Map<String, dynamic> data,
    required String filter,
  }) async {
    final response = await client.from(table).update(data).eq('id', filter).select();
    return response;
  }

  /// Delete data from a table
  static Future<List<Map<String, dynamic>>> delete({
    required String table,
    required String filter,
  }) async {
    final response = await client.from(table).delete().eq('id', filter).select();
    return response;
  }

  /// Real-time subscription
  static RealtimeChannel subscribe({
    required String table,
    required void Function(PostgresChangePayload) callback,
  }) {
    return client
        .channel('public:$table')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: table,
          callback: callback,
        )
        .subscribe();
  }

  /// Upload file to storage
  static Future<String> uploadFile({
    required String bucket,
    required String path,
    required Uint8List fileBytes,
    String? contentType,
  }) async {
    await client.storage.from(bucket).uploadBinary(
      path,
      fileBytes,
      fileOptions: FileOptions(
        contentType: contentType,
      ),
    );
    
    return client.storage.from(bucket).getPublicUrl(path);
  }

  /// Get public URL for a file
  static String getPublicUrl({
    required String bucket,
    required String path,
  }) {
    return client.storage.from(bucket).getPublicUrl(path);
  }
}