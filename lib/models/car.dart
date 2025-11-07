class Car {
  final String id;
  final String name;
  final String? brand;
  final String? model;
  final int? seats;
  final String? transmission;
  final String? fuelType;
  final double basePrice;
  final bool active;
  final String? imageUrl;

  Car({
    required this.id,
    required this.name,
    this.brand,
    this.model,
    this.seats,
    this.transmission,
    this.fuelType,
    required this.basePrice,
    required this.active,
    this.imageUrl,
  });

  factory Car.fromMap(Map<String, dynamic> map) {
    final priceRaw = map['base_price'];
    final price = priceRaw is num ? priceRaw.toDouble() : double.tryParse(priceRaw?.toString() ?? '0') ?? 0;
    return Car(
      id: map['id'].toString(),
      name: map['name']?.toString() ?? 'Car',
      brand: map['brand']?.toString(),
      model: map['model']?.toString(),
      seats: map['seats'] is int ? map['seats'] : int.tryParse(map['seats']?.toString() ?? ''),
      transmission: map['transmission']?.toString(),
      fuelType: map['fuel_type']?.toString(),
      basePrice: price,
      active: (map['active'] == true) || map['active']?.toString() == 'true',
      imageUrl: map['image_url']?.toString(),
    );
  }
}