class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String userType; // 'passenger' or 'driver'
  final String? profileImage;
  final double? rating;
  final int? totalRides;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  // Driver specific fields
  final String? licenseNumber;
  final String? vehicleNumber;
  final String? vehicleType;
  final String? vehicleModel;
  final bool? isOnline;
  final double? currentLatitude;
  final double? currentLongitude;
  
  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.userType,
    this.profileImage,
    this.rating,
    this.totalRides,
    this.isVerified = false,
    required this.createdAt,
    this.updatedAt,
    this.licenseNumber,
    this.vehicleNumber,
    this.vehicleType,
    this.vehicleModel,
    this.isOnline,
    this.currentLatitude,
    this.currentLongitude,
  });
  
  // Compatibility getters
  String get phoneNumber => phone;
  String? get profileImageUrl => profileImage;
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      userType: json['userType'] ?? 'passenger',
      profileImage: json['profileImage'],
      rating: json['rating']?.toDouble(),
      totalRides: json['totalRides'],
      isVerified: json['isVerified'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      licenseNumber: json['licenseNumber'],
      vehicleNumber: json['vehicleNumber'],
      vehicleType: json['vehicleType'],
      vehicleModel: json['vehicleModel'],
      isOnline: json['isOnline'],
      currentLatitude: json['currentLatitude']?.toDouble(),
      currentLongitude: json['currentLongitude']?.toDouble(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'userType': userType,
      'profileImage': profileImage,
      'rating': rating,
      'totalRides': totalRides,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'licenseNumber': licenseNumber,
      'vehicleNumber': vehicleNumber,
      'vehicleType': vehicleType,
      'vehicleModel': vehicleModel,
      'isOnline': isOnline,
      'currentLatitude': currentLatitude,
      'currentLongitude': currentLongitude,
    };
  }

  // Convert to JSON format that matches Supabase users table schema
  Map<String, dynamic> toSupabaseUsersJson() {
    return {
      'id': id,
      'phone': phone,
      'user_type': userType, // Note: snake_case for Supabase
      'name': name,
      'email': email,
      'profile_image': profileImage,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
  
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? userType,
    String? profileImage,
    double? rating,
    int? totalRides,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? licenseNumber,
    String? vehicleNumber,
    String? vehicleType,
    String? vehicleModel,
    bool? isOnline,
    double? currentLatitude,
    double? currentLongitude,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      userType: userType ?? this.userType,
      profileImage: profileImage ?? this.profileImage,
      rating: rating ?? this.rating,
      totalRides: totalRides ?? this.totalRides,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      isOnline: isOnline ?? this.isOnline,
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
    );
  }
  
  bool get isDriver => userType == 'driver';
  bool get isPassenger => userType == 'passenger';
}