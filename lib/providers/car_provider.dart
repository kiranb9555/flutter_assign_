import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/car_repository.dart';
import '../models/car_model.dart';

final carRepositoryProvider = Provider<CarRepository>((ref) => CarRepository());

final availableCarsProvider = FutureProvider<List<Car>>((ref) async {
  final carRepository = ref.watch(carRepositoryProvider);
  return carRepository.getAvailableCars();
});

final carDetailProvider = FutureProvider.family<Car?, String>((ref, carId) async {
  final carRepository = ref.watch(carRepositoryProvider);
  return carRepository.getCarById(carId);
});
