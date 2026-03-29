import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/tour_package.dart';
import '../models/package_booking.dart';
import '../services/package_service.dart';

class PackageProvider with ChangeNotifier {
  List<TourPackage> _packages = [];
  List<PackageBooking> _userBookings = [];
  bool _loading = false;
  String? _error;

  List<TourPackage> get packages => _packages;
  List<PackageBooking> get userBookings => _userBookings;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadPackages() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _packages = await PackageService.fetchPackages();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserBookings() async {
    _loading = true;
    notifyListeners();
    try {
      _userBookings = await PackageService.fetchUserBookings();
    } catch (e) {
      print('Error loading user bookings: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> bookPackage(TourPackage package, DateTime travelDate, int persons) async {
    // We don't set _loading here because the UI handles the loading indicator via a Dialog.
    // Setting _loading = true would trigger a rebuild of the underlying screen which is unnecessary
    // and can cause UI glitches.
    
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');

    final booking = PackageBooking(
      id: '', // Will be assigned by Firestore
      userId: user.uid,
      packageId: package.id,
      packageName: package.name,
      bookingDate: DateTime.now(),
      travelDate: travelDate,
      numberOfPersons: persons,
      totalPrice: package.price * persons,
      status: 'pending',
    );

    await PackageService.createBooking(booking);
    
    // Refresh bookings if needed for local state, but avoid toggling loading unnecessarily
    // Since Dashboard fetches its own data via FutureBuilder, we can skip full loadUserBookings here
    // or implement a silent refresh. For now, let's just update the local list silently if needed.
    // _userBookings = await PackageService.fetchUserBookings(); 
    
    return true;
  }
}
