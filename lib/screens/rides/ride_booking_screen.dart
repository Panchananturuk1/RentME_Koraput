import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';
import '../../services/ride_service.dart';
import '../../models/ride_booking.dart';

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

  @override
  void dispose() {
    _pickupCtrl.dispose();
    _dropoffCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
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
    setState(() {});
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
      );
      final id = await RideService.createRideBooking(booking);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ride booked: $id')),
        );
      }
    } catch (e) {
      // Surface friendly message for common constraint violations
      final msg = e.toString();
      if (msg.contains('ride_pickup_in_future')) {
        setState(() => _error = 'Pickup time must be in the future. Please select a later time.');
      } else {
        setState(() => _error = msg);
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book a Ride')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _pickupCtrl,
                decoration: const InputDecoration(labelText: 'Pickup location'),
                validator: ValidationBuilder().minLength(3).build(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dropoffCtrl,
                decoration: const InputDecoration(labelText: 'Drop-off location'),
                validator: ValidationBuilder().minLength(3).build(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Pickup time'),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: _pickDateTime,
                          child: Text(_pickupTime == null
                              ? 'Select'
                              : _pickupTime!.toString()),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      initialValue: _seats.toString(),
                      decoration: const InputDecoration(labelText: 'Seats'),
                      keyboardType: TextInputType.number,
                      validator: ValidationBuilder().minLength(1).build(),
                      onChanged: (v) {
                        setState(() => _seats = int.tryParse(v) ?? 1);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesCtrl,
                decoration: const InputDecoration(labelText: 'Notes (optional)'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Confirm Ride'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}