class TentBooking {
  final String id;
  final String userId;
  final String tentId;
  final DateTime startDate;
  final DateTime endDate;
  final int nights;
  final int quantity;
  final double totalPrice;
  final String status;

  TentBooking({
    required this.id,
    required this.userId,
    required this.tentId,
    required this.startDate,
    required this.endDate,
    required this.nights,
    required this.quantity,
    required this.totalPrice,
    required this.status,
  });

  Map<String, dynamic> toInsertMap() {
    return {
      'user_id': userId,
      'tent_id': tentId,
      'start_date': startDate.toIso8601String().substring(0, 10),
      'end_date': endDate.toIso8601String().substring(0, 10),
      'nights': nights,
      'quantity': quantity,
      'total_price': totalPrice,
      'status': status,
    };
  }
}