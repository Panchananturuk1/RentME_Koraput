import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://irafyvdazsfqyruyfagr.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlyYWZ5dmRhenNmcXlydXlmYWdyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY0MzkxODIsImV4cCI6MjA3MjAxNTE4Mn0.3nag8aKUCLY1zqoFgyBTuiSWcH2822WeXKsHWfEySmk';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: true, // Set to false in production
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
  static GoTrueClient get auth => Supabase.instance.client.auth;
}