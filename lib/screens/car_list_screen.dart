import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../providers/car_provider.dart';
import '../providers/booking_provider.dart';
import '../models/car_model.dart';
import '../models/booking_model.dart';

class CarListScreen extends ConsumerWidget {
  const CarListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final carsAsync = ref.watch(availableCarsProvider);
    final bookingHistoryAsync = ref.watch(bookingProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Available Cars',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: carsAsync.when(
        data: (cars) {
          if (cars.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.directions_car_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No cars available',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }
          final bookingHistory = bookingHistoryAsync.maybeWhen(
            data: (data) => data,
            orElse: () => const <Booking>[],
          );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (bookingHistory.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: _BookingHistorySection(bookings: bookingHistory),
                ),
              ...cars.map((car) => _CarCard(car: car)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load cars',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.invalidate(availableCarsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookingHistorySection extends StatelessWidget {
  final List<Booking> bookings;

  const _BookingHistorySection({required this.bookings});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    final recentBookings = bookings.reversed.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your recent bookings',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...recentBookings.map(
          (booking) => Card(
            elevation: 1,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  booking.car.imageUrl,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(
                booking.car.fullName,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                '${dateFormat.format(booking.startDate)} - ${dateFormat.format(booking.endDate)} • ${_pickupLocationName(booking.pickupLocation)}',
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currencyFormat.format(booking.totalPrice),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${booking.numberOfDays} days',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  static String _pickupLocationName(String value) {
    switch (value) {
      case 'airport':
        return 'Airport Terminal';
      case 'downtown':
        return 'Downtown Office';
      case 'hotel':
        return 'Hotel Delivery';
      default:
        return value;
    }
  }
}

class _CarCard extends StatelessWidget {
  final Car car;

  const _CarCard({required this.car});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          context.push('/car/${car.id}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: CachedNetworkImage(
                  imageUrl: car.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.directions_car, size: 64, color: Colors.grey),
                  ),
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          car.fullName,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '\$${car.pricePerDay.toInt()}/day',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Row(
                    children: [
                      _buildSpecIcon(Icons.airline_seat_recline_normal, '${car.specs['Seats']} Seats'),
                      const SizedBox(width: 16),
                      _buildSpecIcon(Icons.speed, car.specs['Mileage'] ?? 'N/A'),
                      const SizedBox(width: 16),
                      _buildSpecIcon(Icons.ev_station, car.specs['Fuel Type'] ?? 'N/A'),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        context.push('/car/${car.id}');
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('View Details'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSpecIcon(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }
}
