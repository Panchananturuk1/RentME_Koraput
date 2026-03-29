import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/car.dart';
import '../models/car_rental.dart';

class CarService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<List<Car>> fetchActiveCars() async {
    try {
      final querySnapshot = await _db
          .collection('cars')
          .where('active', isEqualTo: true)
          .get();
      
      final cars = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Car.fromMap(data);
      }).toList();

      // Sort in memory
      cars.sort((a, b) => a.basePrice.compareTo(b.basePrice));
      
      if (cars.isEmpty) {
        await _seedCars();
        return fetchActiveCars();
      }

      return cars;
    } catch (e) {
      print('Error fetching cars: $e');
      return [];
    }
  }

  static Future<void> _seedCars() async {
    final List<Map<String, dynamic>> initialCars = [
      {
        'name': 'Maruti Swift',
        'brand': 'Maruti Suzuki',
        'model': 'Swift VXI',
        'seats': 5,
        'transmission': 'Manual',
        'fuel_type': 'Petrol',
        'base_price': 1200.0,
        'image_url': 'https://imgd.aeplcdn.com/1056x594/n/cw/ec/54399/swift-exterior-right-front-three-quarter-64.jpeg',
        'active': true,
      },
      {
        'name': 'Hyundai Creta',
        'brand': 'Hyundai',
        'model': 'Creta SX',
        'seats': 5,
        'transmission': 'Automatic',
        'fuel_type': 'Diesel',
        'base_price': 2500.0,
        'image_url': 'https://imgd.aeplcdn.com/1056x594/n/cw/ec/141115/creta-exterior-right-front-three-quarter.jpeg',
        'active': true,
      },
      {
        'name': 'Toyota Innova',
        'brand': 'Toyota',
        'model': 'Innova Crysta',
        'seats': 7,
        'transmission': 'Manual',
        'fuel_type': 'Diesel',
        'base_price': 3500.0,
        'image_url': 'https://imgd.aeplcdn.com/1056x594/n/cw/ec/140809/innova-crysta-exterior-right-front-three-quarter.jpeg',
        'active': true,
      },
    ];

    for (final car in initialCars) {
      await _db.collection('cars').add(car);
    }
  }

  static Future<String?> createRental(CarRental rental) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Please log in to rent a car.');
    }
    
    final payload = {
      ...rental.toInsertMap(),
      'user_id': user.uid,
      'created_at': FieldValue.serverTimestamp(),
    };
    
    final docRef = await _db.collection('car_rentals').add(payload);
    return docRef.id;
  }

  /// Fetch car rentals for the current user with nested car info.
  static Future<List<Map<String, dynamic>>> fetchUserRentals() async {
    final user = _auth.currentUser;
    if (user == null) return [];
    
    try {
      final querySnapshot = await _db
          .collection('car_rentals')
          .where('user_id', isEqualTo: user.uid)
          .get();
      
      final rentals = <Map<String, dynamic>>[];
      
      for (var doc in querySnapshot.docs) {
        final rentalData = doc.data();
        rentalData['id'] = doc.id;
        
        // Convert Timestamps to ISO strings
        if (rentalData['start_date'] is Timestamp) {
          rentalData['start_date'] = (rentalData['start_date'] as Timestamp).toDate().toIso8601String();
        }
        if (rentalData['end_date'] is Timestamp) {
          rentalData['end_date'] = (rentalData['end_date'] as Timestamp).toDate().toIso8601String();
        }
        if (rentalData['created_at'] is Timestamp) {
          rentalData['created_at'] = (rentalData['created_at'] as Timestamp).toDate().toIso8601String();
        }
        
        // Fetch car details manually as Firestore doesn't support joins
        final carId = rentalData['car_id'];
        if (carId != null) {
          final carDoc = await _db.collection('cars').doc(carId).get();
          if (carDoc.exists) {
            rentalData['cars'] = carDoc.data();
          }
        }
        
        rentals.add(rentalData);
      }
      
      // Sort in memory
      rentals.sort((a, b) {
        final aTime = DateTime.tryParse(a['created_at']?.toString() ?? '') ?? DateTime(0);
        final bTime = DateTime.tryParse(b['created_at']?.toString() ?? '') ?? DateTime(0);
        return bTime.compareTo(aTime);
      });
      
      return rentals;
    } catch (e) {
      print('Error fetching rentals: $e');
      return [];
    }
  }
}