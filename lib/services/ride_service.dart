import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/ride_booking.dart';

class RideService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<String?> createRideBooking(RideBooking booking) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Please log in to book a ride.');
    }
    
    final payload = {
      ...booking.toInsertMap(),
      'pickup_time': booking.pickupTime, // Firestore handles DateTime directly
      'user_id': user.uid,
      'created_at': FieldValue.serverTimestamp(),
    };
    
    final docRef = await _db.collection('ride_bookings').add(payload);
    return docRef.id;
  }

  /// Fetch ride bookings for the current user.
  static Future<List<Map<String, dynamic>>> fetchUserBookings() async {
    final user = _auth.currentUser;
    if (user == null) return [];
    
    try {
      final querySnapshot = await _db
          .collection('ride_bookings')
          .where('user_id', isEqualTo: user.uid)
          .get();
      
      final bookings = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        
        // Convert Timestamps to ISO strings for consistent parsing in UI
        if (data['pickup_time'] is Timestamp) {
          data['pickup_time'] = (data['pickup_time'] as Timestamp).toDate().toIso8601String();
        }
        // Handle other potential Timestamp fields if necessary
        if (data['created_at'] is Timestamp) {
          data['created_at'] = (data['created_at'] as Timestamp).toDate().toIso8601String();
        }
        
        return data;
      }).toList();

      // Sort in memory to avoid needing a composite index
      bookings.sort((a, b) {
        final aTime = DateTime.tryParse(a['created_at']?.toString() ?? '') ?? DateTime(0);
        final bTime = DateTime.tryParse(b['created_at']?.toString() ?? '') ?? DateTime(0);
        return bTime.compareTo(aTime); // Descending
      });
      
      return bookings;
    } catch (e) {
      print('Error fetching rides: $e');
      return [];
    }
  }
}