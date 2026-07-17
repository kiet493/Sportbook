import 'package:flutter_test/flutter_test.dart';
import 'package:sportbook/models/court_booking.dart';

void main() {
  CourtBooking booking({
    required String date,
    required int startMinutes,
    required int endMinutes,
    String status = CourtSlotStatus.booked,
  }) {
    return CourtBooking(
      id: 'booking-1',
      venueId: 'venue-1',
      venueName: 'SportBook Court',
      courtId: 'court-1',
      courtName: 'Sân 1',
      userId: 'user-1',
      userName: 'Nguyễn Văn A',
      userPhone: '0901234567',
      dateKey: date,
      startMinutes: startMinutes,
      endMinutes: endMinutes,
      totalPrice: 120000,
      participants: 2,
      status: status,
      paymentMethod: '',
      notes: '',
      createdAt: DateTime(2026, 7, 17),
    );
  }

  test('maps persisted booking state to booking history status', () {
    final now = DateTime(2026, 7, 17, 12);

    expect(
      bookingDisplayStatus(
        booking(date: '2026-07-18', startMinutes: 600, endMinutes: 660),
        now: now,
      ),
      'upcoming',
    );
    expect(
      bookingDisplayStatus(
        booking(date: '2026-07-17', startMinutes: 600, endMinutes: 660),
        now: now,
      ),
      'completed',
    );
    expect(
      bookingDisplayStatus(
        booking(
          date: '2026-07-18',
          startMinutes: 600,
          endMinutes: 660,
          status: CourtSlotStatus.cancelled,
        ),
        now: now,
      ),
      'cancelled',
    );
  });

  test('detects overlapping booking ranges', () {
    expect(rangesOverlap(600, 660, 630, 690), isTrue);
    expect(rangesOverlap(600, 660, 660, 720), isFalse);
    expect(rangesOverlap(600, 720, 630, 660), isTrue);
  });

  test('field complex keeps admin CRUD fields when serialized', () {
    const venue = ManagedVenue(
      id: 'venue-1',
      name: 'Cụm sân Phú Nhuận',
      sports: ['Cầu lông'],
      address: '21 Nguyễn Văn Trỗi',
      hours: '06:00 - 22:00',
      pricePerHour: 120000,
      active: true,
      image: 'https://example.com/venue.jpg',
      images: ['https://example.com/venue.jpg'],
      description: 'Sân trong nhà',
      coordinates: '10.7992,106.6741',
      ownerId: 'admin-1',
    );

    final restored = ManagedVenue.fromJson(venue.toJson());
    expect(restored.id, venue.id);
    expect(restored.name, venue.name);
    expect(restored.address, venue.address);
    expect(restored.ownerId, venue.ownerId);
    expect(restored.pricePerHour, venue.pricePerHour);
    expect(restored.active, isTrue);
  });

  test('sport field keeps its complex relationship when serialized', () {
    const court = SportCourt(
      id: 'court-1',
      venueId: 'venue-1',
      name: 'Sân 1',
      sport: 'Cầu lông',
      location: '21 Nguyễn Văn Trỗi',
      capacity: 4,
      images: [],
      pricePerHour: 120000,
      amenities: ['Đèn LED'],
      active: true,
      sortOrder: 1,
    );

    final restored = SportCourt.fromJson(court.toJson());
    expect(restored.id, court.id);
    expect(restored.venueId, court.venueId);
    expect(restored.name, court.name);
    expect(restored.pricePerHour, court.pricePerHour);
    expect(restored.capacity, 4);
    expect(restored.active, isTrue);
  });
}
