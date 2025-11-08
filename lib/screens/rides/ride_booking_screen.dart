import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:form_validator/form_validator.dart';
import '../../services/ride_service.dart';
import '../../models/ride_booking.dart';
import '../../utils/ui_feedback.dart';

class RideBookingScreen extends StatefulWidget {
  const RideBookingScreen({super.key});

  @override
  State<RideBookingScreen> createState() => _RideBookingScreenState();
}

class _RideBookingScreenState extends State<RideBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pickupCtrl = TextEditingController();
  final _dropoffCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime? _pickupTime;
  int _seats = 1;
  bool _loading = false;
  String? _error;

  String _serviceType = 'Economy'; // Economy, Premium, SUV
  double? _fareEstimate;
  String _rideMode = 'Daily'; // Daily, Rental, Outstation

  @override
  void dispose() {
    _pickupCtrl.dispose();
    _dropoffCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _updateEstimate() {
    // Simple local estimate inspired by ride platforms
    // Base fares by service type
    final baseByType = {
      'Economy': 49.0,
      'Premium': 89.0,
      'SUV': 109.0,
    };
    double base = baseByType[_serviceType] ?? 49.0;
    // Seats multiplier
    final seatMultiplier = 1.0 + ((_seats - 1) * 0.2);
    // Time-of-day multiplier (slightly higher evenings)
    final now = _pickupTime ?? DateTime.now();
    final hour = now.hour;
    final timeMultiplier = (hour >= 18 || hour <= 6) ? 1.15 : 1.0;
    // A light distance factor proxy based on input lengths
    final distProxy = ( _pickupCtrl.text.length + _dropoffCtrl.text.length ).clamp(10, 40) / 20.0;
    final estimate = base * seatMultiplier * timeMultiplier * distProxy;
    setState(() {
      _fareEstimate = double.parse(estimate.toStringAsFixed(2));
    });
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now.add(const Duration(hours: 1))),
    );
    if (time == null) return;
    _pickupTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    _updateEstimate();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_pickupTime == null) {
      setState(() => _error = 'Select pickup date and time');
      return;
    }
    // Validate that pickup time is at least 5 minutes in the future in UTC
    final nowUtc = DateTime.now().toUtc();
    final selectedUtc = _pickupTime!.toUtc();
    if (selectedUtc.isBefore(nowUtc.add(const Duration(minutes: 5)))) {
      setState(() => _error = 'Pickup time must be at least 5 minutes from now.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final booking = RideBooking(
        pickupLocation: _pickupCtrl.text.trim(),
        dropoffLocation: _dropoffCtrl.text.trim(),
        pickupTime: _pickupTime!,
        seats: _seats,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        fareEstimate: _fareEstimate,
      );
      final id = await RideService.createRideBooking(booking);
      if (!mounted) return;
      await UIFeedback.showSuccess(
        context,
        'Your ride has been booked successfully.',
      );
    } catch (e) {
      // Surface friendly message for common constraint violations
      final msg = e.toString();
      if (msg.contains('ride_pickup_in_future')) {
        setState(() => _error = 'Pickup time must be in the future. Please select a later time.');
        await UIFeedback.showError(
          context,
          'Pickup time must be in the future. Please select a later time.',
        );
      } else {
        setState(() => _error = msg);
        await UIFeedback.showError(
          context,
          msg,
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showSummarySheet() {
    if (!_formKey.currentState!.validate() || _pickupTime == null) {
      setState(() => _error = 'Please complete all details');
      return;
    }
    _updateEstimate();
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.local_taxi, color: const Color(0xFF0EA5E9), size: 24.sp),
                    SizedBox(width: 8.w),
                    Text('Ride Summary', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 16.h),
                _summaryRow('Pickup', _pickupCtrl.text),
                _summaryRow('Drop-off', _dropoffCtrl.text),
                _summaryRow('Pickup time', _pickupTime!.toString()),
                _summaryRow('Seats', '$_seats'),
                _summaryRow('Type', _serviceType),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Estimated fare', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                    Text('₹${(_fareEstimate ?? 0).toStringAsFixed(2)}', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 20.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : () { Navigator.of(ctx).pop(); _submit(); },
                    child: _loading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Confirm Booking'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100.w, child: Text(label, style: TextStyle(color: const Color(0xFF6B7280), fontSize: 14.sp))),
          Expanded(child: Text(value, style: TextStyle(fontSize: 14.sp))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Ride'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
            children: [
              // Uber-style hero heading
              Text(
                'Go with RentMe',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111827),
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Find a ride for every road with access across Koraput.',
                style: TextStyle(fontSize: 14.sp, color: const Color(0xFF4B5563)),
              ),
              SizedBox(height: 6.h),
              Text(
                'Because the best adventures come to you.',
                style: TextStyle(fontSize: 14.sp, color: const Color(0xFF4B5563)),
              ),

              SizedBox(height: 16.h),

              // Uber-style stacked inputs container
              _uberInputsCard(),

              SizedBox(height: 16.h),
              _notesField(),

              if (_error != null) ...[
                SizedBox(height: 12.h),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],

              SizedBox(height: 24.h),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _onBookRide,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF111827),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  child: _loading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Book Ride'),
                ),
              ),

              SizedBox(height: 12.h),
              TextButton(
                onPressed: () {},
                child: const Text('Download the RentMe app'),
              ),

              SizedBox(height: 40.h),
              _advancedControlsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _heroCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0EA5E9), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Icon(Icons.local_taxi, color: Colors.white, size: 36.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Where to?', style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 4.h),
                Text('Quick and safe rides around Koraput', style: TextStyle(color: Colors.white70, fontSize: 12.sp)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _locationCard() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.my_location, color: const Color(0xFF0EA5E9), size: 20.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: TextFormField(
                    controller: _pickupCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Pickup location',
                      hintText: 'e.g., Jeypore Market',
                    ),
                    validator: ValidationBuilder().minLength(3).build(),
                    onChanged: (_) => _updateEstimate(),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(Icons.location_on, color: const Color(0xFFF59E0B), size: 20.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: TextFormField(
                    controller: _dropoffCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Drop-off location',
                      hintText: 'e.g., Koraput Bus Stand',
                    ),
                    validator: ValidationBuilder().minLength(3).build(),
                    onChanged: (_) => _updateEstimate(),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 8.w,
              children: [
                ActionChip(
                  label: const Text('Use current location'),
                  avatar: const Icon(Icons.near_me, size: 18),
                  onPressed: () {},
                ),
                ActionChip(
                  label: const Text('Home'),
                  avatar: const Icon(Icons.home_outlined, size: 18),
                  onPressed: () {},
                ),
                ActionChip(
                  label: const Text('Work'),
                  avatar: const Icon(Icons.work_outline, size: 18),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Uber-style inputs: stacked, soft gray background, subtle icons
  Widget _uberInputsCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              children: [
                Icon(Icons.circle, size: 10.sp, color: const Color(0xFF111827)),
                SizedBox(width: 12.w),
                Expanded(
                  child: TextFormField(
                    controller: _pickupCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Enter location',
                      border: InputBorder.none,
                    ),
                    validator: ValidationBuilder().minLength(2).build(),
                    onChanged: (_) => _updateEstimate(),
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: const Color(0xFFE5E7EB)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              children: [
                Icon(Icons.stop_circle_outlined, size: 12.sp, color: const Color(0xFF111827)),
                SizedBox(width: 12.w),
                Expanded(
                  child: TextFormField(
                    controller: _dropoffCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Enter destination',
                      border: InputBorder.none,
                    ),
                    validator: ValidationBuilder().minLength(2).build(),
                    onChanged: (_) => _updateEstimate(),
                  ),
                ),
                Icon(Icons.send, color: const Color(0xFF111827)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Advanced controls folded lower on the page
  Widget _advancedControlsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Options', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
        SizedBox(height: 12.h),
        _timeAndSeats(),
        SizedBox(height: 16.h),
        _serviceTypeSelector(),
      ],
    );
  }

  // Book Ride: ensure we have a reasonable default pickup time, then show summary
  void _onBookRide() {
    _pickupTime ??= DateTime.now().add(const Duration(minutes: 10));
    _updateEstimate();
    _showSummarySheet();
  }

  Widget _timeAndSeats() {
    return Row(
      children: [
        Expanded(
          child: Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pickup time', style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280))),
                  SizedBox(height: 8.h),
                  OutlinedButton.icon(
                    onPressed: _pickDateTime,
                    icon: const Icon(Icons.schedule),
                    label: Text(_pickupTime == null ? 'Select' : _pickupTime!.toString()),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Seats', style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280))),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () { setState(() { if (_seats > 1) _seats--; }); _updateEstimate(); },
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text('$_seats', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                      IconButton(
                        onPressed: () { setState(() { _seats++; }); _updateEstimate(); },
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _serviceTypeSelector() {
    final types = ['Economy', 'Premium', 'SUV'];
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ride type', style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280))),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              children: types.map((t) {
                final selected = _serviceType == t;
                return ChoiceChip(
                  selected: selected,
                  label: Text(t),
                  selectedColor: const Color(0xFF0EA5E9).withOpacity(0.15),
                  onSelected: (_) { setState(() { _serviceType = t; }); _updateEstimate(); },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _notesField() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: TextFormField(
          controller: _notesCtrl,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Notes (optional)',
            hintText: 'Any special instructions for the driver',
          ),
        ),
      ),
    );
  }

  Widget _bottomBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, -4)),
        ],
      ),
    child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Estimated fare', style: TextStyle(color: const Color(0xFF6B7280), fontSize: 12.sp)),
                SizedBox(height: 4.h),
                Text('₹${(_fareEstimate ?? 0).toStringAsFixed(2)}', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          SizedBox(
            width: 160.w,
            child: ElevatedButton(
              onPressed: _loading ? null : _showSummarySheet,
              child: _loading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Book Now'),
            ),
          ),
        ],
      ),
    );
  }
}