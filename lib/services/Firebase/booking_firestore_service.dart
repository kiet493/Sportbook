import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/court_booking.dart';

class SlotAlreadyBookedException implements Exception {
  const SlotAlreadyBookedException();
}

class BookingFirestoreService {
  BookingFirestoreService({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _venuesRef => _db
      .collection('fieldComplexes')
      .withConverter<Map<String, dynamic>>(
        fromFirestore: (snap, _) => snap.data() ?? <String, dynamic>{},
        toFirestore: (data, _) => data,
      );

  CollectionReference<Map<String, dynamic>> get _courtsRef => _db
      .collection('sportFields')
      .withConverter<Map<String, dynamic>>(
        fromFirestore: (snap, _) => snap.data() ?? <String, dynamic>{},
        toFirestore: (data, _) => data,
      );

  CollectionReference<Map<String, dynamic>> get _bookingsRef => _db
      .collection('bookings')
      .withConverter<Map<String, dynamic>>(
        fromFirestore: (snap, _) => snap.data() ?? <String, dynamic>{},
        toFirestore: (data, _) => data,
      );

  CollectionReference<Map<String, dynamic>> get _schedulesRef => _db
      .collection('schedules')
      .withConverter<Map<String, dynamic>>(
        fromFirestore: (snap, _) => snap.data() ?? <String, dynamic>{},
        toFirestore: (data, _) => data,
      );

  CollectionReference<Map<String, dynamic>> get _slotLocksRef => _db
      .collection('bookingSlotLocks')
      .withConverter<Map<String, dynamic>>(
        fromFirestore: (snap, _) => snap.data() ?? <String, dynamic>{},
        toFirestore: (data, _) => data,
      );

  Stream<List<ManagedVenue>> watchVenues() {
    return _venuesRef
        .orderBy('name')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(
                (doc) => ManagedVenue.fromJson(doc.data(), fallbackId: doc.id),
              )
              .toList(growable: false),
        );
  }

  Stream<List<SportCourt>> watchCourts(String venueId) {
    return _courtsRef
        .where('complexId', isEqualTo: venueId)
        .snapshots()
        .map((snap) {
          final courts = snap.docs
              .map((doc) => SportCourt.fromJson(doc.data(), fallbackId: doc.id))
              .toList();
          courts.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
          return courts;
        });
  }

  Stream<List<SportCourt>> watchAllCourts() {
    return _courtsRef.snapshots().map((snap) {
      final courts = snap.docs
          .map((doc) => SportCourt.fromJson(doc.data(), fallbackId: doc.id))
          .toList();
      courts.sort((a, b) {
        final venueCompare = a.venueId.compareTo(b.venueId);
        if (venueCompare != 0) return venueCompare;
        return a.sortOrder.compareTo(b.sortOrder);
      });
      return courts;
    });
  }

  Stream<List<CourtBooking>> watchBookings({
    required String venueId,
    required String date,
  }) {
    return _bookingsRef
        .where('venueId', isEqualTo: venueId)
        .where('dateKey', isEqualTo: date)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(
                (doc) => CourtBooking.fromJson(doc.data(), fallbackId: doc.id),
              )
              .toList(growable: false),
        );
  }

  Future<void> upsertVenue(ManagedVenue venue) async {
    final doc = venue.id.isEmpty ? _venuesRef.doc() : _venuesRef.doc(venue.id);
    final saved = venue.copyWith(id: doc.id);
    await doc.set({
      ...saved.toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
      if (venue.id.isEmpty) 'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    final persisted = await doc.get();
    final data = persisted.data();
    if (!persisted.exists ||
        data == null ||
        data['_id'] != doc.id ||
        data['name'] != saved.name ||
        data['location'] != saved.address ||
        data['coordinates'] != saved.coordinates ||
        data['description'] != saved.description ||
        data['ownerId'] != saved.ownerId) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'field-complex-write-incomplete',
        message: 'Cụm sân chưa được lưu đầy đủ trên Firebase.',
      );
    }
  }

  Future<void> deleteVenue(String venueId) async {
    final courts = await _courtsRef
        .where('complexId', isEqualTo: venueId)
        .get();
    final batch = _db.batch();
    batch.delete(_venuesRef.doc(venueId));
    for (final court in courts.docs) {
      batch.delete(court.reference);
      batch.delete(_schedulesRef.doc('${court.id}_default'));
    }
    await batch.commit();
  }

  Future<void> upsertCourt(SportCourt court) async {
    final doc = court.id.isEmpty ? _courtsRef.doc() : _courtsRef.doc(court.id);
    final saved = court.copyWith(id: doc.id);
    await doc.set({
      ...saved.toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
      if (court.id.isEmpty) 'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await _upsertDefaultSchedule(saved);

    final persisted = await doc.get();
    final data = persisted.data();
    if (!persisted.exists ||
        data == null ||
        data['_id'] != doc.id ||
        data['complexId'] != saved.venueId ||
        data['name'] != saved.name ||
        data['type'] != saved.sport ||
        data['location'] != saved.location ||
        data['capacity'] != saved.capacity ||
        data['pricePerHour'] != saved.pricePerHour ||
        data['status'] != (saved.active ? 'active' : 'inactive')) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'sport-field-write-incomplete',
        message: 'Sân chưa được lưu đầy đủ trên Firebase.',
      );
    }
  }

  Future<void> deleteCourt(String courtId) async {
    await _courtsRef.doc(courtId).delete();
    await _schedulesRef.doc('${courtId}_default').delete();
  }

  Future<void> ensureVenueWithDefaultCourts(ManagedVenue venue) async {
    await upsertVenue(venue);
    final courts = await _courtsRef
        .where('complexId', isEqualTo: venue.id)
        .limit(1)
        .get();
    if (courts.docs.isNotEmpty) return;

    final sport = venue.sports.isNotEmpty ? venue.sports.first : 'The thao';
    final batch = _db.batch();
    for (var i = 1; i <= 4; i++) {
      final doc = _courtsRef.doc();
      final court = SportCourt(
        id: doc.id,
        venueId: venue.id,
        name: 'San $i',
        sport: sport,
        location: venue.address,
        capacity: 10,
        images: venue.images,
        pricePerHour: venue.pricePerHour,
        amenities: const [],
        active: true,
        sortOrder: i,
      );
      batch.set(doc, {
        ...court.toJson(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      batch.set(_schedulesRef.doc('${doc.id}_default'), {
        ..._defaultScheduleData(court),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  Future<CourtBooking> createBooking(CourtBooking booking) async {
    return _db.runTransaction((transaction) async {
      final doc = _bookingsRef.doc();
      final saved = booking.copyWith(id: doc.id);
      final lockRefs = <DocumentReference<Map<String, dynamic>>>[
        for (
          var minute = booking.startMinutes;
          minute < booking.endMinutes;
          minute += 30
        )
          _slotLocksRef.doc(
            '${booking.venueId}_${booking.dateKey}_${booking.courtId}_$minute',
          ),
      ];

      for (final lockRef in lockRefs) {
        final lock = await transaction.get(lockRef);
        if (lock.exists) throw const SlotAlreadyBookedException();
      }

      transaction.set(doc, {
        ...saved.toJson(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      for (final lockRef in lockRefs) {
        transaction.set(lockRef, {
          'bookingId': saved.id,
          'venueId': saved.venueId,
          'fieldId': saved.courtId,
          'courtId': saved.courtId,
          'dateKey': saved.dateKey,
          'status': saved.status,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return saved;
    });
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    await _bookingsRef.doc(bookingId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _upsertDefaultSchedule(SportCourt court) async {
    await _schedulesRef.doc('${court.id}_default').set({
      ..._defaultScheduleData(court),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Map<String, dynamic> _defaultScheduleData(SportCourt court) {
    final today = DateTime.now();
    final date = DateTime(today.year, today.month, today.day);
    return {
      '_id': '${court.id}_default',
      'fieldId': court.id,
      'date': Timestamp.fromDate(date),
      'timeSlots': [
        for (var hour = 6; hour <= 22; hour++)
          '${hour.toString().padLeft(2, '0')}:00',
      ],
    };
  }
}
