import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import '../providers/car_provider.dart';
import '../models/car_model.dart';

class CarDetailScreen extends ConsumerWidget {
  final String carId;

  const CarDetailScreen({super.key, required this.carId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final carAsync = ref.watch(carDetailProvider(carId));

    return Scaffold(
      body: carAsync.when(
        data: (car) => _CarDetailContent(car: car!),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text('Failed to load car details'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.invalidate(carDetailProvider(carId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CarDetailContent extends StatefulWidget {
  final Car car;

  const _CarDetailContent({required this.car});

  @override
  State<_CarDetailContent> createState() => _CarDetailContentState();
}

class _CarDetailContentState extends State<_CarDetailContent> {
  DateTimeRange? selectedDates;
  final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

  void _selectDates() async {
    final now = DateTime.now();
    final initialDateRange = DateTimeRange(
      start: now,
      end: now.add(const Duration(days: 1)),
    );

    final picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
      initialDateRange: selectedDates ?? initialDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDates = picked;
      });
    }
  }

  void _bookNow() {
    if (selectedDates == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select rental dates')),
      );
      return;
    }

    context.push('/book/${widget.car.id}');
  }

  @override
  Widget build(BuildContext context) {
    final car = widget.car;
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
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
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Car Title and Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              car.fullName,
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              car.specs['Type'] ?? '',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${currencyFormat.format(car.pricePerDay)}/day',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ),
                          Text(
                            '+ taxes & fees',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Rental Dates
                  _buildSectionTitle('Rental Period'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 20),
                        const SizedBox(width: 16),
                        Expanded(
                          child: selectedDates == null
                              ? const Text('Select rental dates')
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${_formatDate(selectedDates!.start)} - ${_formatDate(selectedDates!.end)}',
                                      style: const TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${selectedDates!.duration.inDays} days',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_calendar),
                          onPressed: _selectDates,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Car Specs
                  _buildSectionTitle('Specifications'),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    children: [
                      _buildSpecItem(Icons.airline_seat_recline_normal, 'Seats', '${car.specs['Seats'] ?? 'N/A'}'),
                      _buildSpecItem(Icons.speed, 'Mileage', car.specs['Mileage'] ?? 'N/A'),
                      _buildSpecItem(Icons.ev_station, 'Fuel Type', car.specs['Fuel Type'] ?? 'N/A'),
                      _buildSpecItem(Icons.settings, 'Transmission', car.specs['Transmission'] ?? 'Automatic'),
                      if (car.specs['Range'] != null)
                        _buildSpecItem(Icons.electric_car, 'Range', car.specs['Range']!),
                      if (car.specs['0-60 mph'] != null)
                        _buildSpecItem(Icons.timer, '0-60 mph', car.specs['0-60 mph']!),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Description
                  _buildSectionTitle('Description'),
                  const SizedBox(height: 8),
                  Text(
                    car.description,
                    style: theme.textTheme.bodyMedium,
                  ),

                  const SizedBox(height: 80), // Space for the bottom button
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total for ${selectedDates?.duration.inDays ?? 0} days',
                    style: theme.textTheme.bodySmall,
                  ),
                  Text(
                    currencyFormat.format(
                      (selectedDates?.duration.inDays ?? 1) * car.pricePerDay,
                    ),
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _bookNow,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Book Now',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildSpecItem(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }
}