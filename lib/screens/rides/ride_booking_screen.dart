import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;
import 'package:form_validator/form_validator.dart';
import '../../services/ride_service.dart';
import '../../models/ride_booking.dart';
import '../../utils/ui_feedback.dart';
import '../../services/places_service.dart';

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
  final PlacesService _places = PlacesService();
  DateTime? _pickupTime;
  int _seats = 1;
  bool _loading = false;
  String? _error;

  String _serviceType = 'Economy'; // Economy, Premium, SUV
  double? _fareEstimate;
  String _rideMode = 'Daily'; // Daily, Rental, Outstation

  // Google Maps state
  GoogleMapController? _mapController;
  Marker? _pickupMarker;
  Marker? _dropoffMarker;
  bool _placingPickup = true; // true => next tap places pickup, false => drop-off
  final CameraPosition _initialCamera = const CameraPosition(
    target: LatLng(18.8130, 82.7120), // Koraput approx
    zoom: 12.5,
  );

  @override
  void dispose() {
    _pickupCtrl.dispose();
    _dropoffCtrl.dispose();
    _notesCtrl.dispose();
    if (!kIsWeb) {
      _mapController?.dispose();
    }
    super.dispose();
  }

  void _updateEstimate() {
    // Base fares and per-km by service type
    final baseByType = {
      'Economy': 49.0,
      'Premium': 89.0,
      'SUV': 109.0,
    };
    final perKmByType = {
      'Economy': 14.0,
      'Premium': 22.0,
      'SUV': 28.0,
    };
    final base = baseByType[_serviceType] ?? 49.0;
    final perKm = perKmByType[_serviceType] ?? 14.0;

    // Seats and time multipliers
    final seatMultiplier = 1.0 + ((_seats - 1) * 0.2);
    final now = _pickupTime ?? DateTime.now();
    final hour = now.hour;
    final timeMultiplier = (hour >= 18 || hour <= 6) ? 1.15 : 1.0;

    // Prefer real distance from map markers when both are set
    double distanceKm;
    if (_pickupMarker != null && _dropoffMarker != null) {
      distanceKm = _haversineKm(_pickupMarker!.position, _dropoffMarker!.position);
    } else {
      // Proxy distance from text inputs when markers not set
      final proxy = (_pickupCtrl.text.length + _dropoffCtrl.text.length).clamp(8, 40);
      distanceKm = proxy / 4.0; // ~2–10 km
    }

    final estimate = (base + distanceKm * perKm) * seatMultiplier * timeMultiplier;
    setState(() {
      _fareEstimate = double.tryParse(estimate.toStringAsFixed(2));
    });
  }

  double _haversineKm(LatLng a, LatLng b) {
    const r = 6371.0; // earth radius km
    final dLat = _deg2rad(b.latitude - a.latitude);
    final dLng = _deg2rad(b.longitude - a.longitude);
    final lat1 = _deg2rad(a.latitude);
    final lat2 = _deg2rad(b.latitude);
    final h = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.sin(dLng / 2) * math.sin(dLng / 2) * math.cos(lat1) * math.cos(lat2);
    final c = 2 * math.atan2(math.sqrt(h), math.sqrt(1 - h));
    return r * c;
  }

  double _deg2rad(double deg) => deg * (math.pi / 180);

  Future<Position?> _getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;
    try {
      return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    } catch (_) {
      return null;
    }
  }

  void _applySelection(bool forPickup, LatLng latLng, String address) {
    setState(() {
      if (forPickup) {
        _pickupCtrl.text = address;
        _pickupMarker = Marker(
          markerId: const MarkerId('pickup'),
          position: latLng,
          infoWindow: const InfoWindow(title: 'Pickup'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        );
      } else {
        _dropoffCtrl.text = address;
        _dropoffMarker = Marker(
          markerId: const MarkerId('dropoff'),
          position: latLng,
          infoWindow: const InfoWindow(title: 'Drop-off'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        );
      }
    });
    _mapController?.animateCamera(CameraUpdate.newLatLng(latLng));
    _updateEstimate();
  }

  Future<void> _openPlaceSearch({required bool forPickup}) async {
    final qCtrl = TextEditingController();
    final bias = _pickupMarker?.position ?? _dropoffMarker?.position;
    Position? current;
    String? currentAddr;

    // Pre-fetch current location/address in the background
    () async {
      current = await _getCurrentPosition();
      if (current != null) {
        currentAddr = await _places.reverseGeocode(current!.latitude, current!.longitude);
      }
    }();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16.r))),
      builder: (ctx) {
        List<PlacePrediction> suggestions = [];
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: StatefulBuilder(
            builder: (ctx, setSheetState) {
              Future<void> _search(String q) async {
                final results = await _places.autocomplete(q, location: bias);
                suggestions = results;
                setSheetState(() {});
              }
              return SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 8.h),
                    Container(height: 4, width: 48, decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(2.r))),
                    Padding(
                      padding: EdgeInsets.all(16.w),
                      child: TextField(
                        controller: qCtrl,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: forPickup ? 'Search pickup' : 'Search destination',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: qCtrl.text.isNotEmpty ? IconButton(icon: const Icon(Icons.clear), onPressed: () { qCtrl.clear(); _search(''); }) : null,
                        ),
                        onChanged: _search,
                      ),
                    ),
                    if (current != null)
                      ListTile(
                        leading: const Icon(Icons.my_location, color: Color(0xFF0EA5E9)),
                        title: const Text('Use current location'),
                        subtitle: Text(currentAddr ?? '${current!.latitude.toStringAsFixed(5)}, ${current!.longitude.toStringAsFixed(5)}'),
                        onTap: () {
                          final latLng = LatLng(current!.latitude, current!.longitude);
                          _applySelection(forPickup, latLng, currentAddr ?? 'Current location');
                          Navigator.pop(ctx);
                        },
                      ),
                    ...suggestions.map((p) => ListTile(
                          leading: const Icon(Icons.place_outlined),
                          title: Text(p.description),
                          onTap: () async {
                            final result = await _places.placeLatLngAndAddress(p.placeId);
                            final latLng = result.$1;
                            final addr = result.$2 ?? p.description;
                            if (latLng != null) {
                              _applySelection(forPickup, latLng, addr);
                              Navigator.pop(ctx);
                            }
                          },
                        )),
                    SizedBox(height: 16.h),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
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
              SizedBox(height: 12.h),
              _mapSection(),

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
                    readOnly: true,
                    onTap: () => _openPlaceSearch(forPickup: true),
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
                    readOnly: true,
                    onTap: () => _openPlaceSearch(forPickup: false),
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

  // Map section allowing tap-to-set pickup/drop-off
  Widget _mapSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ChoiceChip(
              selected: _placingPickup,
              label: const Text('Set pickup on map'),
              onSelected: (_) => setState(() => _placingPickup = true),
            ),
            SizedBox(width: 8.w),
            ChoiceChip(
              selected: !_placingPickup,
              label: const Text('Set drop-off on map'),
              onSelected: (_) => setState(() => _placingPickup = false),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        SizedBox(
          height: 320.h,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: GoogleMap(
              initialCameraPosition: _initialCamera,
              zoomControlsEnabled: true,
              myLocationEnabled: false,
              markers: {
                if (_pickupMarker != null) _pickupMarker!,
                if (_dropoffMarker != null) _dropoffMarker!,
              },
              onMapCreated: (c) => _mapController = c,
              onTap: (pos) {
                setState(() {
                  if (_placingPickup) {
                    _pickupMarker = Marker(
                      markerId: const MarkerId('pickup'),
                      position: pos,
                      infoWindow: const InfoWindow(title: 'Pickup'),
                      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                    );
                  } else {
                    _dropoffMarker = Marker(
                      markerId: const MarkerId('dropoff'),
                      position: pos,
                      infoWindow: const InfoWindow(title: 'Drop-off'),
                      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                    );
                  }
                });
                _updateEstimate();
              },
            ),
          ),
        ),
      ],
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