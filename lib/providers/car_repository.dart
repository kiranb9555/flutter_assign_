import 'package:flutter/foundation.dart';
import '../models/car_model.dart';

class CarRepository {
  final List<Car> _cars = [
    Car(
      id: '1',
      make: 'Toyota',
      model: 'Camry',
      year: 2023,
      pricePerDay: 75.0,
      imageUrl:
          'https://images.unsplash.com/photo-1503736334956-4c8f8e92946d?auto=format&fit=crop&w=1200&q=80',
      description: 'Comfortable and reliable sedan with great fuel economy.',
      specs: {
        'Type': 'Sedan',
        'Seats': 5,
        'Transmission': 'Automatic',
        'Fuel Type': 'Gasoline',
        'Mileage': '28/39 mpg',
      },
    ),
    Car(
      id: '2',
      make: 'Honda',
      model: 'CR-V',
      year: 2023,
      pricePerDay: 85.0,
      imageUrl:
          'https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?auto=format&fit=crop&w=1200&q=80',
      description: 'Spacious SUV with excellent safety features.',
      specs: {
        'Type': 'SUV',
        'Seats': 5,
        'Transmission': 'Automatic',
        'Fuel Type': 'Hybrid',
        'Mileage': '40/35 mpg',
      },
    ),
    Car(
      id: '3',
      make: 'Tesla',
      model: 'Model 3',
      year: 2023,
      pricePerDay: 120.0,
      imageUrl:
          'https://images.unsplash.com/photo-1502877338535-766e1452684a?auto=format&fit=crop&w=1000&q=80',
      description: 'Fully electric vehicle with autopilot capabilities.',
      specs: {
        'Type': 'Electric',
        'Seats': 5,
        'Range': '358 miles',
        '0-60 mph': '3.1s',
        'Top Speed': '162 mph',
      },
      isAvailable: true,
    ),
  ];

  Future<List<Car>> getAvailableCars() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _cars.where((car) => car.isAvailable).toList();
  }

  Future<Car?> getCarById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _cars.firstWhere((car) => car.id == id);
    } catch (e) {
      return null;
    }
  }
}
