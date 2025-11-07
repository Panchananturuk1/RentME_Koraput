import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/car.dart';
import '../models/car_rental.dart';

class CarService {
  static final SupabaseClient _client = SupabaseConfig.client;

  static Future<List<Car>> fetchActiveCars() async {
    final res = await _client
        .from('cars')
        .select()
        .eq('active', true)
        .order('base_price', ascending: true);
    return (res as List<dynamic>).map((e) => Car.fromMap(e as Map<String, dynamic>)).toList();
  }

  static Future<String?> createRental(CarRental rental) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Please log in to rent a car.');
    }
    final payload = {
      ...rental.toInsertMap(),
      'user_id': user.id,
    };
    final inserted = await _client
        .from('car_rentals')
        .insert(payload)
        .select('id')
        .single();
    return inserted['id']?.toString();
  }

  /// Fetch car rentals for the current user with nested car info.
  static Future<List<Map<String, dynamic>>> fetchUserRentals() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return [];
    final res = await _client
        .from('car_rentals')
        .select('id, car_id, start_date, end_date, days, quantity, total_price, status, created_at, cars:car_id(name, brand, model, base_price)')
        .eq('user_id', uid)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(res as List);
  }
}