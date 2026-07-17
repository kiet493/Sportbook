import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/court_booking.dart';
import '../models/venue.dart';
import '../services/Firebase/booking_firestore_service.dart';
import 'registration_providers.dart';

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

final allSportCourtsProvider = StreamProvider<List<SportCourt>>((ref) {
  return ref.watch(bookingFirestoreServiceProvider).watchAllCourts();
});

final publicVenuesProvider = Provider<AsyncValue<List<Venue>>>((ref) {
  final venuesAsync = ref.watch(managedVenuesProvider);
  final courtsAsync = ref.watch(allSportCourtsProvider);

  if (venuesAsync.hasError) {
    return AsyncError(
      venuesAsync.error!,
      venuesAsync.stackTrace ?? StackTrace.current,
    );
  }
  if (courtsAsync.hasError) {
    return AsyncError(
      courtsAsync.error!,
      courtsAsync.stackTrace ?? StackTrace.current,
    );
  }

  final venues = venuesAsync.valueOrNull;
  final courts = courtsAsync.valueOrNull;
  if (venues == null || courts == null) return const AsyncLoading();

  return AsyncData(_toPublicVenues(venues, courts));
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

final userBookingsProvider =
    StreamProvider.family<List<CourtBooking>, String>((ref, userId) {
      return ref
          .watch(bookingFirestoreServiceProvider)
          .watchUserBookings(userId);
    });

final adminBookingsProvider = StreamProvider<List<CourtBooking>>((ref) {
  return ref.watch(bookingFirestoreServiceProvider).watchAllBookings();
});

final currentUserBookingInfosProvider =
    Provider<AsyncValue<List<BookingInfo>>>((ref) {
      final session = ref.watch(sessionProvider);
      if (session == null) return const AsyncData([]);

      final bookingsAsync = ref.watch(userBookingsProvider(session.user.id));
      if (bookingsAsync.hasError) {
        return AsyncError(
          bookingsAsync.error!,
          bookingsAsync.stackTrace ?? StackTrace.current,
        );
      }

      final bookings = bookingsAsync.valueOrNull;
      if (bookings == null) return const AsyncLoading();
      final venues = ref.watch(publicVenuesProvider).valueOrNull ?? const [];
      return AsyncData([
        for (final booking in bookings)
          bookingInfoFromCourtBooking(
            booking,
            venue: venues
                .where((venue) => venue.firestoreId == booking.venueId)
                .firstOrNull,
          ),
      ]);
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

class BookingCancelNotifier extends AsyncNotifier<void> {
  @override
  void build() {}

  Future<String?> cancel(String bookingId) async {
    state = const AsyncLoading();
    try {
      await ref
          .read(bookingFirestoreServiceProvider)
          .cancelBooking(bookingId);
      state = const AsyncData(null);
      ref.invalidate(venueBookingsProvider);
      ref.invalidate(userBookingsProvider);
      return null;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return 'Không thể hủy lịch đặt sân lúc này.';
    }
  }
}

final bookingCancelProvider = AsyncNotifierProvider<BookingCancelNotifier, void>(
  BookingCancelNotifier.new,
);

BookingInfo bookingInfoFromCourtBooking(
  CourtBooking booking, {
  Venue? venue,
}) {
  final resolvedVenue = venue ??
      Venue(
        id: _stableIntId(booking.venueId),
        firestoreId: booking.venueId,
        name: booking.venueName.isEmpty ? 'Sân cầu lông' : booking.venueName,
        sport: const ['Cầu lông'],
        distance: '',
        rating: 0,
        reviews: 0,
        hours: '',
        price: '',
        priceNum: 0,
        available: true,
        image: _fallbackVenueImage,
        images: const [_fallbackVenueImage],
        address: '',
        description: '',
      );

  return BookingInfo(
    id: booking.id,
    venue: resolvedVenue,
    date: _formatBookingDate(booking.dateKey),
    time: booking.timeRange,
    status: bookingDisplayStatus(booking),
    amount: _formatVnd(booking.totalPrice),
    court: booking.courtName.isEmpty ? 'Sân đã đặt' : booking.courtName,
  );
}

String _formatBookingDate(String rawDate) {
  final date = DateTime.tryParse(rawDate);
  if (date == null) return rawDate;
  const weekdays = [
    'Thứ 2',
    'Thứ 3',
    'Thứ 4',
    'Thứ 5',
    'Thứ 6',
    'Thứ 7',
    'Chủ nhật',
  ];
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '${weekdays[date.weekday - 1]}, $day/$month/${date.year}';
}

List<Venue> _toPublicVenues(List<ManagedVenue> venues, List<SportCourt> courts) {
  return venues
      .where((venue) => venue.active)
      .expand((venue) {
        final venueCourts = courts
            .where(
              (court) =>
                  court.venueId == venue.id &&
                  court.active &&
                  _isBadmintonSport(court.sport),
            )
            .toList(growable: false);
        final hasBadmintonVenueTag = venue.sports.any(_isBadmintonSport);
        if (venueCourts.isEmpty && !hasBadmintonVenueTag) {
          return const <Venue>[];
        }
        final prices = venueCourts
            .map((court) => court.pricePerHour)
            .where((price) => price > 0)
            .toList(growable: false);
        final price = prices.isEmpty ? venue.pricePerHour : prices.reduce(_min);
        final images = venue.images.isNotEmpty
            ? venue.images
            : (venue.image.isEmpty ? <String>[] : <String>[venue.image]);
        final image = images.isNotEmpty ? images.first : _fallbackVenueImage;

        return [
          Venue(
            id: _stableIntId(venue.id),
            firestoreId: venue.id,
            name: venue.name,
            sport: const ['Cầu lông'],
            distance: 'Đang cập nhật',
            rating: 4.8,
            reviews: 0,
            hours: venue.hours,
            price: '${_formatVnd(price)}/h',
            priceNum: price,
            available: venue.active,
            image: image,
            images: images.isEmpty ? <String>[image] : images,
            address: venue.address,
            description: venue.description,
          ),
        ];
      })
      .toList(growable: false);
}

int _min(int a, int b) => a < b ? a : b;

int _stableIntId(String value) {
  return value.codeUnits.fold<int>(
    0,
    (hash, codeUnit) => ((hash * 31) + codeUnit) & 0x7fffffff,
  );
}

String _formatVnd(int value) {
  final raw = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < raw.length; i++) {
    final remaining = raw.length - i;
    buffer.write(raw[i]);
    if (remaining > 1 && remaining % 3 == 1) buffer.write('.');
  }
  return '${buffer}đ';
}

bool _isBadmintonSport(String value) {
  final normalized = value.toLowerCase().trim();
  return normalized.contains('cầu lông') ||
      normalized.contains('cau long') ||
      normalized.contains('badminton');
}

const _fallbackVenueImage =
    'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=800&h=500&fit=crop&auto=format';
