import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/tour_package.dart';
import '../models/package_booking.dart';

class PackageService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<List<TourPackage>> fetchPackages() async {
    try {
      final querySnapshot = await _db.collection('packages').where('active', isEqualTo: true).get();
      
      final packages = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return TourPackage.fromMap(data);
      }).toList();

      if (packages.isEmpty) {
        await seedPackages();
        return fetchPackages();
      }

      return packages;
    } catch (e) {
      print('Error fetching packages: $e');
      return [];
    }
  }

  static Future<void> seedPackages() async {
    final List<Map<String, dynamic>> initialPackages = [
      {
        'name': 'Koraput Adventure Special',
        'description': 'The ultimate all-in-one experience covering the best of Koraput.',
        'places': ['Deomali', 'Duduma Waterfall', 'Putsil'],
        'inclusions': [
          '4 Persons',
          '2 Tents for Night Stay',
          'One Car with Driver',
          'All Meals Included'
        ],
        'price': 4999.0,
        'duration_days': 2,
        'max_persons': 4,
        'image_url': 'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?q=80&w=1000&auto=format&fit=crop',
        'active': true,
      },
    ];

    for (final pkg in initialPackages) {
      await _db.collection('packages').add(pkg);
    }
  }

  static Future<String?> createBooking(PackageBooking booking) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Please log in to book a package.');
    }
    
    final payload = {
      ...booking.toInsertMap(),
      'user_id': user.uid,
      'created_at': FieldValue.serverTimestamp(),
    };
    
    final docRef = await _db.collection('package_bookings').add(payload);
    return docRef.id;
  }

  static Future<List<PackageBooking>> fetchUserBookings() async {
    final user = _auth.currentUser;
    if (user == null) return [];
    
    try {
      final querySnapshot = await _db
          .collection('package_bookings')
          .where('user_id', isEqualTo: user.uid)
          .get();
      
      final bookings = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return PackageBooking.fromMap(data);
      }).toList();

      // Sort in memory by booking date (newest first)
      bookings.sort((a, b) => b.bookingDate.compareTo(a.bookingDate));
      
      return bookings;
    } catch (e) {
      print('Error fetching package bookings: $e');
      return [];
    }
  }
}
