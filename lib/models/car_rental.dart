class CarRental {
  final String carId;
  final DateTime startDate;
  final DateTime endDate;
  final int days;
  final int quantity;
  final double totalPrice;
  final String status;

  CarRental({
    required this.carId,
    required this.startDate,
    required this.endDate,
    required this.days,
    required this.quantity,
    required this.totalPrice,
    this.status = 'pending',
  });

  Map<String, dynamic> toInsertMap() {
    return {
      'car_id': carId,
      'start_date': startDate.toIso8601String().substring(0, 10),
      'end_date': endDate.toIso8601String().substring(0, 10),
      'days': days,
      'quantity': quantity,
      'total_price': totalPrice,
      'status': status,
    };
  }
}