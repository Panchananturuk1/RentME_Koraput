import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/tent.dart';
import '../models/tent_booking.dart';

class TentService {
  static final SupabaseClient _client = SupabaseConfig.client;

  static Future<List<Tent>> fetchActiveTents() async {
    final res = await _client
        .from('tents')
        .select()
        .eq('active', true)
        .order('base_price', ascending: true);
    return (res as List<dynamic>).map((e) => Tent.fromMap(e as Map<String, dynamic>)).toList();
  }

  static Future<String?> createBooking(TentBooking booking) async {
    final inserted = await _client
        .from('tent_bookings')
        .insert(booking.toInsertMap())
        .select('id')
        .single();
    return inserted['id'] as String?;
  }

  /// Fetch bookings for the current user with nested tent details.
  static Future<List<Map<String, dynamic>>> fetchUserBookings() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) {
      return [];
    }
    final res = await _client
        .from('tent_bookings')
        .select('id, tent_id, start_date, end_date, nights, quantity, total_price, status, created_at, tents:tent_id(name, capacity, base_price)')
        .eq('user_id', uid)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(res as List);
  }
}