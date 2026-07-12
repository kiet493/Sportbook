import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/court_booking.dart';
import '../services/Firebase/booking_firestore_service.dart';

final bookingFirestoreServiceProvider = Provider<BookingFirestoreService>((
  ref,
) {
  return BookingFirestoreService();
});

final managedVenuesProvider = StreamProvider<List<ManagedVenue>>((ref) {
  return ref.watch(bookingFirestoreServiceProvider).watchVenues();
});

final venueCourtsProvider = StreamProvider.family<List<SportCourt>, String>((
  ref,
  venueId,
) {
  return ref.watch(bookingFirestoreServiceProvider).watchCourts(venueId);
});

class BookingDateQuery {
  final String venueId;
  final String dateKey;

  const BookingDateQuery({required this.venueId, required this.dateKey});

  @override
  bool operator ==(Object other) {
    return other is BookingDateQuery &&
        other.venueId == venueId &&
        other.dateKey == dateKey;
  }

  @override
  int get hashCode => Object.hash(venueId, dateKey);
}

final venueBookingsProvider =
    StreamProvider.family<List<CourtBooking>, BookingDateQuery>((ref, query) {
      return ref
          .watch(bookingFirestoreServiceProvider)
          .watchBookings(venueId: query.venueId, date: query.dateKey);
    });

class BookingSubmitNotifier extends AsyncNotifier<CourtBooking?> {
  @override
  CourtBooking? build() => null;

  Future<String?> submit(CourtBooking booking) async {
    state = const AsyncLoading();
    try {
      final saved = await ref
          .read(bookingFirestoreServiceProvider)
          .createBooking(booking);
      state = AsyncData(saved);
      ref.invalidate(
        venueBookingsProvider(
          BookingDateQuery(venueId: booking.venueId, dateKey: booking.dateKey),
        ),
      );
      return null;
    } on SlotAlreadyBookedException {
      state = const AsyncData(null);
      return 'Khung gio nay vua co nguoi dat. Vui long chon khung khac.';
    } catch (e, st) {
      state = AsyncError(e, st);
      return 'Khong the dat san luc nay, vui long thu lai.';
    }
  }
}

final bookingSubmitProvider =
    AsyncNotifierProvider<BookingSubmitNotifier, CourtBooking?>(
      BookingSubmitNotifier.new,
    );
