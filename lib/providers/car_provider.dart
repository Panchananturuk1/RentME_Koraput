import 'package:flutter/foundation.dart';
import '../models/car.dart';
import '../models/car_rental.dart';
import '../services/car_service.dart';

class CarProvider extends ChangeNotifier {
  final List<Car> _cars = [];
  Car? _selectedCar;
  DateTime? _startDate;
  DateTime? _endDate;
  int _quantity = 1;
  bool _loading = false;
  String? _error;

  List<Car> get cars => _cars;
  Car? get selectedCar => _selectedCar;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  int get quantity => _quantity;
  bool get loading => _loading;
  String? get error => _error;

  int get days {
    if (_startDate == null || _endDate == null) return 0;
    final diff = _endDate!.difference(_startDate!).inDays;
    return diff > 0 ? diff : 0;
  }

  double get totalPrice {
    if (_selectedCar == null) return 0;
    return (_selectedCar!.basePrice) * (days) * (_quantity);
  }

  Future<void> loadCars() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final list = await CarService.fetchActiveCars();
      _cars
        ..clear()
        ..addAll(list);
      if (_cars.isEmpty) {
        _error = 'No cars available. Please try again later.';
      }
    } catch (e) {
      // Surface a friendly message, common cause is RLS unauthorized when not logged in
      final msg = e.toString();
      if (msg.contains('Unauthorized') || msg.contains('permission') || msg.contains('RLS')) {
        _error = 'Please log in to view available cars.';
      } else {
        _error = 'Failed to load cars: $msg';
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void setSelectedCar(Car? car) {
    _selectedCar = car;
    notifyListeners();
  }

  void setDates(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    if (_startDate != null && _endDate != null && _endDate!.isBefore(_startDate!)) {
      _error = 'End date must be after start date';
    } else {
      _error = null;
    }
    notifyListeners();
  }

  void setQuantity(int q) {
    _quantity = q < 1 ? 1 : q;
    notifyListeners();
  }

  Future<String?> createBooking() async {
    if (_selectedCar == null) {
      _error = 'Select a car';
      notifyListeners();
      return null;
    }
    if (_startDate == null || _endDate == null || days <= 0) {
      _error = 'Select valid start and end dates';
      notifyListeners();
      return null;
    }
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final booking = CarRental(
        carId: _selectedCar!.id,
        startDate: _startDate!,
        endDate: _endDate!,
        days: days,
        quantity: _quantity,
        totalPrice: totalPrice,
      );
      final id = await CarService.createRental(booking);
      return id;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}