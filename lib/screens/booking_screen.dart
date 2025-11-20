import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/car_model.dart';
import '../models/booking_model.dart';
import '../providers/booking_provider.dart';
import '../providers/car_provider.dart';

class BookingFormScreen extends ConsumerStatefulWidget {
  final String carId;

  const BookingFormScreen({super.key, required this.carId});

  @override
  ConsumerState<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends ConsumerState<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  DateTimeRange? _selectedDates;
  String? _selectedPickupLocation;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDates() async {
    final now = DateTime.now();
    final initialDateRange = DateTimeRange(
      start: now,
      end: now.add(const Duration(days: 1)),
    );

    final picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
      initialDateRange: _selectedDates ?? initialDateRange,
    );

    if (picked != null) {
      setState(() {
        _selectedDates = picked;
      });
    }
  }

  Future<void> _submitBooking(Car car) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDates == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select rental dates')),
      );
      return;
    }
    if (_selectedPickupLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a pickup location')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await Future.delayed(const Duration(seconds: 1));

      final rentalDays = _selectedDates!.end.difference(_selectedDates!.start).inDays <= 0
          ? 1
          : _selectedDates!.end.difference(_selectedDates!.start).inDays;
      final pickupFee = _selectedPickupLocation == 'hotel' ? 25.0 : 0.0;
      final totalPrice = (car.pricePerDay * rentalDays) + pickupFee;

      final booking = Booking(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        car: car,
        customerName: _nameController.text.trim(),
        customerEmail: _emailController.text.trim(),
        customerPhone: _phoneController.text.trim(),
        startDate: _selectedDates!.start,
        endDate: _selectedDates!.end,
        pickupLocation: _selectedPickupLocation!,
        totalPrice: totalPrice,
        bookingDate: DateTime.now(),
      );

      ref.read(bookingProvider.notifier).addBooking(booking);

      if (mounted) {
        context.go('/confirmation', extra: booking);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create booking. Please try again.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final carAsync = ref.watch(carDetailProvider(widget.carId));

    return carAsync.when(
      data: (car) => _buildForm(car!),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text('Failed to load car details'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.invalidate(carDetailProvider(widget.carId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm(Car car) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Booking'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Your Vehicle'),

              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(car.imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              car.fullName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${car.specs['Type']} • ${car.specs['Seats']} Seats',
                              style: theme.textTheme.bodySmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${currencyFormat.format(car.pricePerDay)}/day',
                              style: TextStyle(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              _buildSectionTitle('Rental Period'),

              const SizedBox(height: 8),
              InkWell(
                onTap: _selectDates,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 20),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _selectedDates == null
                            ? const Text('Select rental dates')
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${_formatDate(_selectedDates!.start)} - ${_formatDate(_selectedDates!.end)}',
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    '${_selectedDates!.duration.inDays} days',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              _buildSectionTitle('Pickup Location'),

              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedPickupLocation,
                decoration: InputDecoration(
                  hintText: 'Select pickup location',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'airport',
                    child: Text('Airport Terminal'),
                  ),
                  DropdownMenuItem(
                    value: 'downtown',
                    child: Text('Downtown Office'),
                  ),
                  DropdownMenuItem(
                    value: 'hotel',
                    child: Text('Hotel Delivery (Additional \$25)'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedPickupLocation = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a pickup location';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              _buildSectionTitle('Personal Information'),

              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Home Address',
                  prefixIcon: Icon(Icons.home_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              _buildSectionTitle('Special Requests (Optional)'),

              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Any special requests or notes...',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 32),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: true,
                    onChanged: (value) {},
                  ),
                  const Expanded(
                    child: Text(
                      'I agree to the Terms & Conditions and Privacy Policy. I understand that additional charges may apply for late returns or damages.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Total and Book Button
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildPriceRow('Daily Rate', currencyFormat.format(car.pricePerDay)),
                      const SizedBox(height: 8),
                      _buildPriceRow(
                        'Rental Period',
                        _selectedDates != null
                            ? '${_selectedDates!.duration.inDays} days'
                            : '0 days',
                      ),
                      const SizedBox(height: 8),
                      _buildPriceRow(
                        'Pickup Location',
                        _selectedPickupLocation != null
                            ? _getPickupLocationName(_selectedPickupLocation!)
                            : 'Not selected',
                      ),
                      const Divider(height: 32),
                      _buildPriceRow(
                        'Total',
                        _selectedDates != null
                            ? currencyFormat.format(
                                car.pricePerDay * _selectedDates!.duration.inDays +
                                    (_selectedPickupLocation == 'hotel' ? 25 : 0),
                              )
                            : '\$0.00',
                        isTotal: true,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : () => _submitBooking(car),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Confirm Booking',
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 18 : null,
            color: isTotal ? Theme.of(context).primaryColor : null,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  String _getPickupLocationName(String value) {
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