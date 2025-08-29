class RideModel {
  final String id;
  final String passengerId;
  final String? driverId;
  final String status;
  final double pickupLatitude;
  final double pickupLongitude;
  final String pickupAddress;
  final double destinationLatitude;
  final double destinationLongitude;
  final String destinationAddress;
  final double estimatedFare;
  final double? actualFare;
  final double? distance;
  final int? duration; // in minutes
  final String paymentMethod;
  final String? paymentStatus;
  final DateTime requestedAt;
  final DateTime? acceptedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final double? passengerRating;
  final double? driverRating;
  final String? passengerReview;
  final String? driverReview;
  final String? vehicleType;
  final bool isSurgeActive;
  final double surgeMultiplier;
  
  RideModel({
    required this.id,
    required this.passengerId,
    this.driverId,
    required this.status,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.pickupAddress,
    required this.destinationLatitude,
    required this.destinationLongitude,
    required this.destinationAddress,
    required this.estimatedFare,
    this.actualFare,
    this.distance,
    this.duration,
    required this.paymentMethod,
    this.paymentStatus,
    required this.requestedAt,
    this.acceptedAt,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
    this.cancellationReason,
    this.passengerRating,
    this.driverRating,
    this.passengerReview,
    this.driverReview,
    this.vehicleType,
    this.isSurgeActive = false,
    this.surgeMultiplier = 1.0,
  });
  
  factory RideModel.fromJson(Map<String, dynamic> json) {
    return RideModel(
      id: json['id'] ?? '',
      passengerId: json['passengerId'] ?? '',
      driverId: json['driverId'],
      status: json['status'] ?? 'requested',
      pickupLatitude: json['pickupLatitude']?.toDouble() ?? 0.0,
      pickupLongitude: json['pickupLongitude']?.toDouble() ?? 0.0,
      pickupAddress: json['pickupAddress'] ?? '',
      destinationLatitude: json['destinationLatitude']?.toDouble() ?? 0.0,
      destinationLongitude: json['destinationLongitude']?.toDouble() ?? 0.0,
      destinationAddress: json['destinationAddress'] ?? '',
      estimatedFare: json['estimatedFare']?.toDouble() ?? 0.0,
      actualFare: json['actualFare']?.toDouble(),
      distance: json['distance']?.toDouble(),
      duration: json['duration'],
      paymentMethod: json['paymentMethod'] ?? 'cash',
      paymentStatus: json['paymentStatus'],
      requestedAt: DateTime.parse(json['requestedAt'] ?? DateTime.now().toIso8601String()),
      acceptedAt: json['acceptedAt'] != null ? DateTime.parse(json['acceptedAt']) : null,
      startedAt: json['startedAt'] != null ? DateTime.parse(json['startedAt']) : null,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      cancelledAt: json['cancelledAt'] != null ? DateTime.parse(json['cancelledAt']) : null,
      cancellationReason: json['cancellationReason'],
      passengerRating: json['passengerRating']?.toDouble(),
      driverRating: json['driverRating']?.toDouble(),
      passengerReview: json['passengerReview'],
      driverReview: json['driverReview'],
      vehicleType: json['vehicleType'],
      isSurgeActive: json['isSurgeActive'] ?? false,
      surgeMultiplier: json['surgeMultiplier']?.toDouble() ?? 1.0,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'passengerId': passengerId,
      'driverId': driverId,
      'status': status,
      'pickupLatitude': pickupLatitude,
      'pickupLongitude': pickupLongitude,
      'pickupAddress': pickupAddress,
      'destinationLatitude': destinationLatitude,
      'destinationLongitude': destinationLongitude,
      'destinationAddress': destinationAddress,
      'estimatedFare': estimatedFare,
      'actualFare': actualFare,
      'distance': distance,
      'duration': duration,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'requestedAt': requestedAt.toIso8601String(),
      'acceptedAt': acceptedAt?.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
      'cancellationReason': cancellationReason,
      'passengerRating': passengerRating,
      'driverRating': driverRating,
      'passengerReview': passengerReview,
      'driverReview': driverReview,
      'vehicleType': vehicleType,
      'isSurgeActive': isSurgeActive,
      'surgeMultiplier': surgeMultiplier,
    };
  }
  
  RideModel copyWith({
    String? id,
    String? passengerId,
    String? driverId,
    String? status,
    double? pickupLatitude,
    double? pickupLongitude,
    String? pickupAddress,
    double? destinationLatitude,
    double? destinationLongitude,
    String? destinationAddress,
    double? estimatedFare,
    double? actualFare,
    double? distance,
    int? duration,
    String? paymentMethod,
    String? paymentStatus,
    DateTime? requestedAt,
    DateTime? acceptedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
    String? cancellationReason,
    double? passengerRating,
    double? driverRating,
    String? passengerReview,
    String? driverReview,
    String? vehicleType,
    bool? isSurgeActive,
    double? surgeMultiplier,
  }) {
    return RideModel(
      id: id ?? this.id,
      passengerId: passengerId ?? this.passengerId,
      driverId: driverId ?? this.driverId,
      status: status ?? this.status,
      pickupLatitude: pickupLatitude ?? this.pickupLatitude,
      pickupLongitude: pickupLongitude ?? this.pickupLongitude,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      destinationLatitude: destinationLatitude ?? this.destinationLatitude,
      destinationLongitude: destinationLongitude ?? this.destinationLongitude,
      destinationAddress: destinationAddress ?? this.destinationAddress,
      estimatedFare: estimatedFare ?? this.estimatedFare,
      actualFare: actualFare ?? this.actualFare,
      distance: distance ?? this.distance,
      duration: duration ?? this.duration,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      requestedAt: requestedAt ?? this.requestedAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      passengerRating: passengerRating ?? this.passengerRating,
      driverRating: driverRating ?? this.driverRating,
      passengerReview: passengerReview ?? this.passengerReview,
      driverReview: driverReview ?? this.driverReview,
      vehicleType: vehicleType ?? this.vehicleType,
      isSurgeActive: isSurgeActive ?? this.isSurgeActive,
      surgeMultiplier: surgeMultiplier ?? this.surgeMultiplier,
    );
  }
  
  bool get isRequested => status == 'requested';
  bool get isAccepted => status == 'accepted';
  bool get isStarted => status == 'started';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  
  bool get canBeCancelled => isRequested || isAccepted;
  bool get canBeRated => isCompleted;
}