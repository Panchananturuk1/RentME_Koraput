import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/tent.dart';
import '../models/tent_booking.dart';
import '../services/tent_service.dart';
import '../config/supabase_config.dart';

class TentProvider extends ChangeNotifier {
  final List<Tent> _tents = [];
  Tent? _selectedTent;
  DateTime? _startDate;
  DateTime? _endDate;
  int _quantity = 1;
  bool _loading = false;
  String? _error;

  List<Tent> get tents => _tents;
  Tent? get selectedTent => _selectedTent;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  int get quantity => _quantity;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadTents() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final list = await TentService.fetchActiveTents();
      _tents
        ..clear()
        ..addAll(list);
      if (_tents.isNotEmpty) {
        _selectedTent = _tents.first;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void setSelectedTent(Tent? tent) {
    _selectedTent = tent;
    notifyListeners();
  }

  void setDates(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    notifyListeners();
  }

  void setQuantity(int q) {
    _quantity = q < 1 ? 1 : q;
    notifyListeners();
  }

  int get nights {
    if (_startDate == null || _endDate == null) return 0;
    final diff = _endDate!.difference(_startDate!).inDays;
    return diff > 0 ? diff : 0;
  }

  double get totalPrice {
    if (_selectedTent == null) return 0;
    return _selectedTent!.basePrice * nights * _quantity;
  }

  Future<String?> createBooking() async {
    if (_selectedTent == null || _startDate == null || _endDate == null || nights == 0) {
      _error = 'Please select tent and valid dates';
      notifyListeners();
      return null;
    }

    final user = SupabaseConfig.auth.currentUser;
    if (user == null) {
      _error = 'Please sign in to book';
      notifyListeners();
      return null;
    }

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final booking = TentBooking(
        id: 'temp',
        userId: user.id,
        tentId: _selectedTent!.id,
        startDate: _startDate!,
        endDate: _endDate!,
        nights: nights,
        quantity: _quantity,
        totalPrice: totalPrice,
        status: 'pending',
      );
      final id = await TentService.createBooking(booking);
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