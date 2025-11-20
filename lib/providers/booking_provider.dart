import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/booking_model.dart';

final bookingProvider =
    StateNotifierProvider<BookingNotifier, AsyncValue<List<Booking>>>(
  (ref) => BookingNotifier(),
);

class BookingNotifier extends StateNotifier<AsyncValue<List<Booking>>> {
  BookingNotifier() : super(const AsyncValue.data([]));

  void addBooking(Booking booking) {
    final currentBookings = state.value ?? [];
    state = AsyncValue.data([...currentBookings, booking]);
  }

  void clearHistory() {
    state = const AsyncValue.data([]);
  }

  Booking? getLatestBooking() {
    final bookings = state.value;
    if (bookings == null || bookings.isEmpty) return null;
    return bookings.last;
  }
}
