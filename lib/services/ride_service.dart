import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/ride_booking.dart';

class RideService {
  static final SupabaseClient _client = SupabaseConfig.client;

  static Future<String?> createRideBooking(RideBooking booking) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Please log in to book a ride.');
    }
    final payload = {
      ...booking.toInsertMap(),
      // Ensure server-side check uses a future UTC timestamp
      'pickup_time': booking.pickupTime.toUtc().toIso8601String(),
      'user_id': user.id,
    };
    final inserted = await _client
        .from('ride_bookings')
        .insert(payload)
        .select('id')
        .single();
    return inserted['id']?.toString();
  }

  /// Fetch ride bookings for the current user.
  static Future<List<Map<String, dynamic>>> fetchUserBookings() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return [];
    final res = await _client
        .from('ride_bookings')
        .select('id, pickup_location, dropoff_location, pickup_time, seats, fare_estimate, status, created_at')
        .eq('user_id', uid)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(res as List);
  }
}