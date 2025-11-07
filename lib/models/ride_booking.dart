class RideBooking {
  final String pickupLocation;
  final String dropoffLocation;
  final DateTime pickupTime;
  final int seats;
  final String? notes;
  final double? fareEstimate;
  final String status;

  RideBooking({
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.pickupTime,
    required this.seats,
    this.notes,
    this.fareEstimate,
    this.status = 'pending',
  });

  Map<String, dynamic> toInsertMap() {
    return {
      'pickup_location': pickupLocation,
      'dropoff_location': dropoffLocation,
      'pickup_time': pickupTime.toIso8601String(),
      'seats': seats,
      'notes': notes,
      'fare_estimate': fareEstimate,
      'status': status,
    };
  }
}