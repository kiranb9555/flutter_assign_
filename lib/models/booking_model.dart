import 'package:flutter/material.dart';
import 'car_model.dart';

class Booking {
  final String id;
  final Car car;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final DateTime startDate;
  final DateTime endDate;
  final String pickupLocation;
  final double totalPrice;
  final DateTime bookingDate;
  final String status; // e.g., 'confirmed', 'completed', 'cancelled'

  Booking({
    required this.id,
    required this.car,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.startDate,
    required this.endDate,
    required this.pickupLocation,
    required this.totalPrice,
    required this.bookingDate,
    this.status = 'confirmed',
  });

  int get numberOfDays {
    final days = endDate.difference(startDate).inDays + 1;
    return days <= 0 ? 1 : days;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'car': car.toMap(),
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'pickupLocation': pickupLocation,
      'totalPrice': totalPrice,
      'bookingDate': bookingDate.toIso8601String(),
      'status': status,
    };
  }

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'] ?? '',
      car: Car.fromMap(Map<String, dynamic>.from(map['car'] ?? {})),
      customerName: map['customerName'] ?? '',
      customerEmail: map['customerEmail'] ?? '',
      customerPhone: map['customerPhone'] ?? '',
      startDate: DateTime.parse(map['startDate'] ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(map['endDate'] ?? DateTime.now().add(const Duration(days: 1)).toIso8601String()),
      pickupLocation: map['pickupLocation'] ?? '',
      totalPrice: (map['totalPrice'] ?? 0.0).toDouble(),
      bookingDate: DateTime.parse(map['bookingDate'] ?? DateTime.now().toIso8601String()),
      status: map['status'] ?? 'confirmed',
    );
  }

  Booking copyWith({
    String? id,
    Car? car,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    DateTime? startDate,
    DateTime? endDate,
    String? pickupLocation,
    double? totalPrice,
    DateTime? bookingDate,
    String? status,
  }) {
    return Booking(
      id: id ?? this.id,
      car: car ?? this.car,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      totalPrice: totalPrice ?? this.totalPrice,
      bookingDate: bookingDate ?? this.bookingDate,
      status: status ?? this.status,
    );
  }
}
