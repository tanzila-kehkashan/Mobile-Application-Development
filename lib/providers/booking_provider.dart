import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/booking_model.dart';
import '../services/booking_service.dart';
import 'auth_provider.dart';

final bookingServiceProvider = Provider<BookingService>((ref) {
  return BookingService();
});

// Stream of all user's bookings
final userBookingsProvider = StreamProvider<List<Booking>>((ref) {
  final currentUser = ref.watch(authStateProvider).value;
  if (currentUser == null) {
    return Stream.value([]);
  }

  final bookingService = ref.watch(bookingServiceProvider);
  return bookingService.getUserBookings(currentUser.uid);
});

// ✅ FIXED: Stream of upcoming bookings (client-side filtering to avoid composite index)
final upcomingBookingsProvider = StreamProvider<List<Booking>>((ref) {
  final currentUser = ref.watch(authStateProvider).value;
  if (currentUser == null) {
    return Stream.value([]);
  }

  final bookingService = ref.watch(bookingServiceProvider);

  // Get all user bookings and filter client-side
  return bookingService.getUserBookings(currentUser.uid). map((bookings) {
    final now = DateTime.now();
    return bookings
        .where((booking) =>
    booking.eventDate.isAfter(now) &&
        booking.bookingStatus == 'confirmed')
        .toList()
      .. sort((a, b) => a.eventDate.compareTo(b.eventDate));
  });
});

// ✅ FIXED: Stream of past bookings (client-side filtering to avoid composite index)
final pastBookingsProvider = StreamProvider<List<Booking>>((ref) {
  final currentUser = ref.watch(authStateProvider).value;
  if (currentUser == null) {
    return Stream.value([]);
  }

  final bookingService = ref.watch(bookingServiceProvider);

  // Get all user bookings and filter client-side
  return bookingService.getUserBookings(currentUser.uid).map((bookings) {
    final now = DateTime.now();
    return bookings
        .where((booking) => booking.eventDate.isBefore(now))
        .toList()
      ..sort((a, b) => b.eventDate.compareTo(a.eventDate)); // Descending order for past
  });
});