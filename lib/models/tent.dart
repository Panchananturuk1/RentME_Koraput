class Tent {
  final String id;
  final String name;
  final String? description;
  final int capacity;
  final double basePrice;
  final List<String> amenities;
  final bool active;

  Tent({
    required this.id,
    required this.name,
    this.description,
    required this.capacity,
    required this.basePrice,
    required this.amenities,
    required this.active,
  });

  factory Tent.fromMap(Map<String, dynamic> map) {
    return Tent(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      capacity: (map['capacity'] ?? 2) as int,
      basePrice: (map['base_price'] as num).toDouble(),
      amenities: (map['amenities'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      active: (map['active'] as bool?) ?? true,
    );
  }
}