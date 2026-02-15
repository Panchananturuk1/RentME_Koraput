import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/tent.dart';
import '../models/tent_booking.dart';

class TentService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<List<Tent>> fetchActiveTents() async {
    try {
      final querySnapshot = await _db
          .collection('tents')
          .where('active', isEqualTo: true)
          .get();
      
      final tents = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Tent.fromMap(data);
      }).toList();

      // Sort in memory to avoid index requirements
      tents.sort((a, b) => a.basePrice.compareTo(b.basePrice));
      
      if (tents.isEmpty) {
        await seedTents();
        return fetchActiveTents();
      }

      return tents;
    } catch (e) {
      print('Error fetching tents: $e');
      return [];
    }
  }

  static Future<void> seedTents() async {
    final List<Map<String, dynamic>> initialTents = [
      {
        'name': 'Basic Dome Tent',
        'description': 'A simple and affordable tent for 2 people.',
        'capacity': 2,
        'base_price': 499.0,
        'amenities': ['Waterproof', 'Easy Setup'],
        'active': true,
      },
      {
        'name': 'Family Camping Tent',
        'description': 'Spacious tent suitable for a small family.',
        'capacity': 4,
        'base_price': 999.0,
        'amenities': ['2 Rooms', 'Ventilation', 'Waterproof'],
        'active': true,
      },
      {
        'name': 'Luxury Glamping Tent',
        'description': 'Premium experience with extra comfort.',
        'capacity': 2,
        'base_price': 1999.0,
        'amenities': ['Bedding', 'Lighting', 'Power Outlet'],
        'active': true,
      },
    ];

    for (final tent in initialTents) {
      await _db.collection('tents').add(tent);
    }
  }

  static Future<String?> createBooking(TentBooking booking) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Please log in to book a tent.');
    }
    
    final payload = {
      ...booking.toInsertMap(),
      'user_id': user.uid,
      'created_at': FieldValue.serverTimestamp(),
    };
    
    final docRef = await _db.collection('tent_bookings').add(payload);
    return docRef.id;
  }

  /// Fetch bookings for the current user with nested tent details.
  static Future<List<Map<String, dynamic>>> fetchUserBookings() async {
    final user = _auth.currentUser;
    if (user == null) return [];
    
    try {
      final querySnapshot = await _db
          .collection('tent_bookings')
          .where('user_id', isEqualTo: user.uid)
          .get();
      
      final bookings = <Map<String, dynamic>>[];
      
      for (var doc in querySnapshot.docs) {
        final bookingData = doc.data();
        bookingData['id'] = doc.id;
        
        // Convert Timestamps to ISO strings
        if (bookingData['start_date'] is Timestamp) {
          bookingData['start_date'] = (bookingData['start_date'] as Timestamp).toDate().toIso8601String();
        }
        if (bookingData['end_date'] is Timestamp) {
          bookingData['end_date'] = (bookingData['end_date'] as Timestamp).toDate().toIso8601String();
        }
        if (bookingData['created_at'] is Timestamp) {
          bookingData['created_at'] = (bookingData['created_at'] as Timestamp).toDate().toIso8601String();
        }
        
        // Fetch tent details manually as Firestore doesn't support joins
        final tentId = bookingData['tent_id'];
        if (tentId != null) {
          final tentDoc = await _db.collection('tents').doc(tentId).get();
          if (tentDoc.exists) {
            bookingData['tents'] = tentDoc.data();
          }
        }
        
        bookings.add(bookingData);
      }
      
      // Sort in memory
      bookings.sort((a, b) {
        final aTime = DateTime.tryParse(a['created_at']?.toString() ?? '') ?? DateTime(0);
        final bTime = DateTime.tryParse(b['created_at']?.toString() ?? '') ?? DateTime(0);
        return bTime.compareTo(aTime);
      });
      
      return bookings;
    } catch (e) {
      print('Error fetching tent bookings: $e');
      return [];
    }
  }
}