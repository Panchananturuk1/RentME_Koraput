class PackageBooking {
  final String id;
  final String userId;
  final String packageId;
  final String packageName;
  final DateTime bookingDate;
  final DateTime travelDate;
  final int numberOfPersons;
  final double totalPrice;
  final String status;

  PackageBooking({
    required this.id,
    required this.userId,
    required this.packageId,
    required this.packageName,
    required this.bookingDate,
    required this.travelDate,
    required this.numberOfPersons,
    required this.totalPrice,
    required this.status,
  });

  Map<String, dynamic> toInsertMap() {
    return {
      'user_id': userId,
      'package_id': packageId,
      'package_name': packageName,
      'booking_date': bookingDate.toIso8601String(),
      'travel_date': travelDate.toIso8601String(),
      'number_of_persons': numberOfPersons,
      'total_price': totalPrice,
      'status': status,
    };
  }

  factory PackageBooking.fromMap(Map<String, dynamic> map) {
    return PackageBooking(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      packageId: map['package_id'] ?? '',
      packageName: map['package_name'] ?? '',
      bookingDate: DateTime.tryParse(map['booking_date'] ?? '') ?? DateTime.now(),
      travelDate: DateTime.tryParse(map['travel_date'] ?? '') ?? DateTime.now(),
      numberOfPersons: map['number_of_persons'] ?? 1,
      totalPrice: (map['total_price'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
    );
  }
}
