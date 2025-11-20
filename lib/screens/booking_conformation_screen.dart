import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../models/booking_model.dart';
import '../providers/booking_provider.dart';

class BookingConfirmationScreen extends ConsumerWidget {
  const BookingConfirmationScreen({super.key, this.booking});

  final Booking? booking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingState = ref.watch(bookingProvider);
    final bookingData = booking ?? bookingState.whenOrNull(
      data: (bookings) => bookings.isNotEmpty ? bookings.last : null,
    );

    if (bookingData == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Booking Confirmed'),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              'We couldn\'t find booking details. Please try creating a booking again.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');
    final dayFormat = DateFormat('MMM d, yyyy');
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final rentalDays = bookingData.numberOfDays;
    final basePrice = bookingData.car.pricePerDay * rentalDays;
    final pickupFee = (bookingData.totalPrice - basePrice).clamp(0, double.infinity);

    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Confirmed'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 60,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Booking Confirmed!',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Your booking has been successfully created',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 32),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Booking Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildDetailRow('Booking ID', '#${bookingData.id.substring(0, 6)}'),
                    Divider(height: 24),
                    Text(
                      'Vehicle Information',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          width: 80,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[200],
                            image: DecorationImage(
                              image: NetworkImage(bookingData.car.imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bookingData.car.fullName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text('${bookingData.car.specs['Transmission'] ?? 'Automatic'} • ${bookingData.car.specs['Seats'] ?? '5'} Seats'),
                              SizedBox(height: 4),
                              Text(
                                currencyFormat.format(bookingData.car.pricePerDay) + '/day',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Divider(height: 24),
                    Text(
                      'Rental Period',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8),
                    _buildDetailRow('Pickup', dateFormat.format(bookingData.startDate)),
                    SizedBox(height: 8),
                    _buildDetailRow('Return', dateFormat.format(bookingData.endDate)),
                    SizedBox(height: 8),
                    _buildDetailRow('Duration', '$rentalDays day${rentalDays == 1 ? '' : 's'}'),
                    SizedBox(height: 8),
                    _buildDetailRow('Pickup location', _pickupLocationName(bookingData.pickupLocation)),
                    Divider(height: 24),
                    Text(
                      'Payment Summary',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8),
                    _buildPriceRow('$rentalDays days x ${currencyFormat.format(bookingData.car.pricePerDay)}', currencyFormat.format(basePrice)),
                    if (pickupFee > 0)
                      _buildPriceRow('Pickup fee', currencyFormat.format(pickupFee)),
                    Divider(height: 16),
                    _buildPriceRow(
                      'Total',
                      currencyFormat.format(bookingData.totalPrice),
                      isTotal: true,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Next Steps',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            _buildNextStep(
              Icons.email_outlined,
              'Check your email',
              'We\'ve sent a confirmation email with all the details of your booking.',
            ),
            SizedBox(height: 16),
            _buildNextStep(
              Icons.phone_android_outlined,
              'Download our app',
              'Get real-time updates and manage your booking on the go.',
            ),
            SizedBox(height: 16),
            _buildNextStep(
              Icons.help_outline,
              'Need help?',
              'Contact our 24/7 customer support for any questions about your booking.',
            ),
            SizedBox(height: 32),
            FilledButton(
              onPressed: () {
                Share.share(
                  '🚗 *Car Rental Booking Confirmed!*\n\n'
                  'Vehicle: ${bookingData.car.fullName}\n'
                  'Dates: ${dayFormat.format(bookingData.startDate)} - ${dayFormat.format(bookingData.endDate)}\n'
                  'Total: ${currencyFormat.format(bookingData.totalPrice)}\n\n'
                  'Pickup: ${_pickupLocationName(bookingData.pickupLocation)}\n'
                  'Thank you for choosing our service!',
                );
              },
              child: Text('Share Booking Details'),
            ),
            SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                context.go('/');
              },
              child: Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : null,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : null,
              color: isTotal ? Colors.green : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextStep(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 24, color: Colors.blue),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _pickupLocationName(String value) {
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