class Car {
  final String id;
  final String make;
  final String model;
  final int year;
  final double pricePerDay;
  final String imageUrl;
  final String description;
  final Map<String, dynamic> specs;
  final bool isAvailable;

  Car({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    required this.pricePerDay,
    required this.imageUrl,
    required this.description,
    required this.specs,
    this.isAvailable = true,
  });

  // Helper getter for full car name
  String get fullName => '$year $make $model';

  // Convert Car to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'make': make,
      'model': model,
      'year': year,
      'pricePerDay': pricePerDay,
      'imageUrl': imageUrl,
      'description': description,
      'specs': specs,
      'isAvailable': isAvailable,
    };
  }

  // Create Car from Map
  factory Car.fromMap(Map<String, dynamic> map) {
    return Car(
      id: map['id'] ?? '',
      make: map['make'] ?? '',
      model: map['model'] ?? '',
      year: map['year']?.toInt() ?? 0,
      pricePerDay: map['pricePerDay']?.toDouble() ?? 0.0,
      imageUrl: map['imageUrl'] ?? '',
      description: map['description'] ?? '',
      specs: Map<String, dynamic>.from(map['specs'] ?? {}),
      isAvailable: map['isAvailable'] ?? true,
    );
  }
}
