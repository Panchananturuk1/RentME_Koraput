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
}