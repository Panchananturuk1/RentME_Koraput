class TourPackage {
  final String id;
  final String name;
  final String description;
  final List<String> places;
  final List<String> inclusions;
  final double price;
  final int durationDays;
  final int maxPersons;
  final String imageUrl;
  final bool active;

  TourPackage({
    required this.id,
    required this.name,
    required this.description,
    required this.places,
    required this.inclusions,
    required this.price,
    required this.durationDays,
    required this.maxPersons,
    required this.imageUrl,
    required this.active,
  });

  factory TourPackage.fromMap(Map<String, dynamic> map) {
    return TourPackage(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      places: List<String>.from(map['places'] ?? []),
      inclusions: List<String>.from(map['inclusions'] ?? []),
      price: (map['price'] ?? 0).toDouble(),
      durationDays: map['duration_days'] ?? 1,
      maxPersons: map['max_persons'] ?? 4,
      imageUrl: map['image_url'] ?? '',
      active: map['active'] ?? true,
    );
  }
}
