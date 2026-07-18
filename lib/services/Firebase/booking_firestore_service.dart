import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../models/court_booking.dart';

class SlotAlreadyBookedException implements Exception {
  const SlotAlreadyBookedException();
}

class VenueDataException implements Exception {
  final String message;

  const VenueDataException(this.message);

  @override
  String toString() => message;
}

class ActiveVenueBookingsException implements Exception {
  final String venueName;

  const ActiveVenueBookingsException(this.venueName);
}

class ActiveCourtBookingsException implements Exception {
  final String courtName;

  const ActiveCourtBookingsException(this.courtName);
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

  CollectionReference<Map<String, dynamic>> get _favoritesRef => _db
      .collection('favorites')
      .withConverter<Map<String, dynamic>>(
        fromFirestore: (snap, _) => snap.data() ?? <String, dynamic>{},
        toFirestore: (data, _) => data,
      );

  Stream<Set<String>> watchFavoriteVenueIds(String userId) => _favoritesRef
      .where('userId', isEqualTo: userId)
      .snapshots()
      .map((snap) => snap.docs.map((doc) => doc.data()['venueId']?.toString() ?? '').where((id) => id.isNotEmpty).toSet());

  Future<void> toggleFavorite({required String userId, required String venueId}) async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null || firebaseUser.uid != userId) {
      throw FirebaseException(
        plugin: 'firebase_auth',
        code: 'unauthenticated',
        message: 'Firebase Auth chưa có phiên hợp lệ.',
      );
    }
    final doc = _favoritesRef.doc('${userId}_$venueId');
    debugPrint('Current UID: ${firebaseUser.uid}');
    debugPrint('Favorite field ID: $venueId');
    debugPrint('Favorite document path: ${doc.path}');
    try {
      await _db.runTransaction((transaction) async {
        final current = await transaction.get(doc);
        if (current.exists) {
          transaction.delete(doc);
        } else {
          transaction.set(doc, {
            'userId': userId,
            'venueId': venueId,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      });
    } on FirebaseException catch (error, stackTrace) {
      debugPrint('Firestore error code: ${error.code}');
      debugPrint('Firestore error message: ${error.message}');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

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

  /// Reads the `schedules` collection and filters the calendar client-side.
  /// This supports documents stored with either `dateKey` or Firestore
  /// Timestamp `date`, without requiring a composite Firestore index.
  Stream<List<CourtSchedule>> watchSchedulesForDate(String selectedDateKey) {
    return _schedulesRef.snapshots().map((snap) {
      return snap.docs
          .map(
            (doc) => CourtSchedule.fromJson(
              doc.data(),
              fallbackId: doc.id,
            ),
          )
          .where(
            (schedule) =>
                schedule.fieldId.isNotEmpty &&
                schedule.dateKey == selectedDateKey,
          )
          .toList(growable: false);
    });
  }

  Stream<List<CourtBooking>> watchBookings({
    required String venueId,
    required String date,
  }) {
    return _slotLocksRef
        .where('venueId', isEqualTo: venueId)
        .where('dateKey', isEqualTo: date)
        .snapshots()
        .map((snap) {
          return snap.docs.map((doc) {
            final data = doc.data();
            final minute = _readLockMinute(doc.id, data);
            return CourtBooking(
              id: data['bookingId']?.toString() ?? doc.id,
              venueId: data['venueId']?.toString() ?? venueId,
              venueName: '',
              courtId:
                  data['fieldId']?.toString() ??
                  data['courtId']?.toString() ??
                  '',
              courtName: '',
              userId: '',
              userName: '',
              userPhone: '',
              dateKey: data['dateKey']?.toString() ?? date,
              startMinutes: minute,
              endMinutes: minute + 30,
              totalPrice: 0,
              participants: 0,
              status: data['status']?.toString() ?? CourtSlotStatus.booked,
              paymentMethod: '',
              notes: '',
              createdAt: DateTime.now(),
            );
          }).toList(growable: false);
        });
  }

  Stream<List<CourtBooking>> watchUserBookings(String userId) {
    return _bookingsRef
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snap) {
          final bookings = snap.docs
              .map(
                (doc) => CourtBooking.fromJson(doc.data(), fallbackId: doc.id),
              )
              .toList();
          bookings.sort((a, b) {
            final dateCompare = b.dateKey.compareTo(a.dateKey);
            if (dateCompare != 0) return dateCompare;
            return b.startMinutes.compareTo(a.startMinutes);
          });
          return bookings;
        });
  }

  Stream<List<CourtBooking>> watchAllBookings() {
    return _bookingsRef.snapshots().map((snap) {
      final bookings = snap.docs
          .map(
            (doc) => CourtBooking.fromJson(doc.data(), fallbackId: doc.id),
          )
          .toList();
      bookings.sort((a, b) {
        final dateCompare = b.dateKey.compareTo(a.dateKey);
        if (dateCompare != 0) return dateCompare;
        return b.startMinutes.compareTo(a.startMinutes);
      });
      return bookings;
    });
  }

  Future<void> upsertVenue(ManagedVenue venue) async {
    final normalized = _normalizeVenue(venue);
    final doc = venue.id.isEmpty ? _venuesRef.doc() : _venuesRef.doc(venue.id);
    final saved = normalized.copyWith(id: doc.id);
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
        data['ownerId'] != saved.ownerId ||
        data['hours'] != saved.hours ||
        data['pricePerHour'] != saved.pricePerHour ||
        data['isActive'] != saved.active) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'field-complex-write-incomplete',
        message: 'Cụm sân chưa được lưu đầy đủ trên Firebase.',
      );
    }
  }

  Future<void> deleteVenue(String venueId) async {
    final venueSnapshot = await _venuesRef.doc(venueId).get();
    if (!venueSnapshot.exists) return;
    final venue = ManagedVenue.fromJson(
      venueSnapshot.data() ?? <String, dynamic>{},
      fallbackId: venueSnapshot.id,
    );
    if (await _hasUpcomingBookings(venueId: venueId)) {
      throw ActiveVenueBookingsException(venue.name);
    }

    final courts = await _courtsRef
        .where('complexId', isEqualTo: venueId)
        .get();
    final references = <DocumentReference<Object?>>[];
    for (final court in courts.docs) {
      final schedules = await _schedulesRef
          .where('fieldId', isEqualTo: court.id)
          .get();
      references.addAll(schedules.docs.map((doc) => doc.reference));
      references.add(court.reference);
    }
    final locks = await _slotLocksRef
        .where('venueId', isEqualTo: venueId)
        .get();
    references.addAll(locks.docs.map((doc) => doc.reference));
    references.add(_venuesRef.doc(venueId));
    await _deleteReferences(references);
  }

  Future<void> upsertCourt(SportCourt court) async {
    final normalized = _normalizeCourt(court);
    final doc = court.id.isEmpty ? _courtsRef.doc() : _courtsRef.doc(court.id);
    final saved = normalized.copyWith(id: doc.id);
    final batch = _db.batch();
    batch.set(doc, {
      ...saved.toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
      if (court.id.isEmpty) 'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    batch.set(_schedulesRef.doc('${doc.id}_default'), {
      ..._defaultScheduleData(saved),
      'updatedAt': FieldValue.serverTimestamp(),
      if (court.id.isEmpty) 'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await batch.commit();

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
    final courtSnapshot = await _courtsRef.doc(courtId).get();
    if (!courtSnapshot.exists) return;
    final court = SportCourt.fromJson(
      courtSnapshot.data() ?? <String, dynamic>{},
      fallbackId: courtSnapshot.id,
    );
    if (await _hasUpcomingBookings(courtId: courtId)) {
      throw ActiveCourtBookingsException(court.name);
    }

    final schedules = await _schedulesRef
        .where('fieldId', isEqualTo: courtId)
        .get();
    final locks = await _slotLocksRef
        .where('fieldId', isEqualTo: courtId)
        .get();
    await _deleteReferences([
      ...schedules.docs.map((doc) => doc.reference),
      ...locks.docs.map((doc) => doc.reference),
      _courtsRef.doc(courtId),
    ]);
  }

  Future<void> ensureVenueWithDefaultCourts(ManagedVenue venue) async {
    await upsertVenue(venue);
    final courts = await _courtsRef
        .where('complexId', isEqualTo: venue.id)
        .limit(1)
        .get();
    if (courts.docs.isNotEmpty) return;

    final sport = venue.sports.isNotEmpty ? venue.sports.first : 'Cầu lông';
    final batch = _db.batch();
    for (var i = 1; i <= 4; i++) {
      final doc = _courtsRef.doc();
      final court = SportCourt(
        id: doc.id,
        venueId: venue.id,
        name: 'Sân $i',
        sport: sport,
        location: venue.address,
        capacity: 4,
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
    _validateBooking(booking);
    final doc = _bookingsRef.doc();
    final saved = booking.copyWith(id: doc.id);
    try {
      await doc.set({
        ...saved.toJson(),
        // Keep the persisted booking schema consistent with Firestore Rules.
        // `CourtBooking.toJson` is also used by local UI code, where these
        // values are strings; the Firestore document must use timestamps.
        'startTime': Timestamp.fromDate(saved.scheduledStart!),
        'endTime': Timestamp.fromDate(saved.scheduledEnd!),
        'scheduledStart': Timestamp.fromDate(saved.scheduledStart!),
        'scheduledEnd': Timestamp.fromDate(saved.scheduledEnd!),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (error, stackTrace) {
      debugPrint('Booking error type: ${error.runtimeType}');
      debugPrint('Booking error: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
    return saved;
  }

  Future<void> cancelBooking(String bookingId) async {
    await _db.runTransaction((transaction) async {
      final bookingRef = _bookingsRef.doc(bookingId);
      final snapshot = await transaction.get(bookingRef);
      final data = snapshot.data();
      if (!snapshot.exists || data == null) {
        throw StateError('Không tìm thấy lịch đặt sân.');
      }

      final booking = CourtBooking.fromJson(data, fallbackId: snapshot.id);

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
      final existingLocks = <DocumentReference<Map<String, dynamic>>>[];
      for (final lockRef in lockRefs) {
        final lock = await transaction.get(lockRef);
        if (lock.exists) existingLocks.add(lockRef);
      }

      transaction.update(bookingRef, {
        'status': CourtSlotStatus.cancelled,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      for (final lockRef in existingLocks) {
        transaction.delete(lockRef);
      }
    });
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    if (status == CourtSlotStatus.cancelled) {
      await cancelBooking(bookingId);
      return;
    }
    await _bookingsRef.doc(bookingId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  ManagedVenue _normalizeVenue(ManagedVenue venue) {
    final sports = venue.sports
        .map((sport) => sport.trim())
        .where((sport) => sport.isNotEmpty)
        .toSet()
        .toList(growable: false);
    final images = venue.images
        .map((image) => image.trim())
        .where((image) => image.isNotEmpty)
        .toSet()
        .toList(growable: false);
    final image = venue.image.trim().isNotEmpty
        ? venue.image.trim()
        : (images.firstOrNull ?? '');

    final normalized = venue.copyWith(
      name: venue.name.trim(),
      sports: sports,
      address: venue.address.trim(),
      hours: venue.hours.trim(),
      image: image,
      images: image.isEmpty
          ? images
          : <String>[image, ...images.where((item) => item != image)],
      description: venue.description.trim(),
      coordinates: venue.coordinates.trim(),
      ownerId: venue.ownerId.trim(),
    );

    if (normalized.name.isEmpty) {
      throw const VenueDataException('Tên cụm sân không được để trống.');
    }
    if (normalized.ownerId.isEmpty) {
      throw const VenueDataException('Cụm sân phải có Owner ID.');
    }
    if (normalized.address.isEmpty) {
      throw const VenueDataException('Địa chỉ cụm sân không được để trống.');
    }
    if (normalized.sports.isEmpty) {
      throw const VenueDataException('Cụm sân phải có ít nhất một môn.');
    }
    if (normalized.hours.isEmpty || normalized.pricePerHour <= 0) {
      throw const VenueDataException('Giờ mở cửa hoặc giá sân không hợp lệ.');
    }
    return normalized;
  }

  SportCourt _normalizeCourt(SportCourt court) {
    final normalized = court.copyWith(
      name: court.name.trim(),
      venueId: court.venueId.trim(),
      sport: court.sport.trim(),
      location: court.location.trim(),
      images: court.images
          .map((image) => image.trim())
          .where((image) => image.isNotEmpty)
          .toSet()
          .toList(growable: false),
      amenities: court.amenities
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toSet()
          .toList(growable: false),
    );

    if (normalized.venueId.isEmpty || normalized.name.isEmpty) {
      throw const VenueDataException('Sân con phải thuộc một cụm sân và có tên.');
    }
    if (normalized.sport.isEmpty || normalized.location.isEmpty) {
      throw const VenueDataException('Môn thể thao hoặc vị trí sân không hợp lệ.');
    }
    if (normalized.capacity <= 0 || normalized.pricePerHour <= 0) {
      throw const VenueDataException('Sức chứa hoặc giá sân không hợp lệ.');
    }
    return normalized;
  }

  Future<bool> _hasUpcomingBookings({String? venueId, String? courtId}) async {
    Query<Map<String, dynamic>> query = _bookingsRef;
    if (venueId != null) {
      query = query.where('venueId', isEqualTo: venueId);
    } else if (courtId != null) {
      query = query.where('fieldId', isEqualTo: courtId);
    } else {
      return false;
    }

    final snapshot = await query.get();
    final now = DateTime.now();
    for (final doc in snapshot.docs) {
      final booking = CourtBooking.fromJson(doc.data(), fallbackId: doc.id);
      if (booking.status == CourtSlotStatus.cancelled ||
          booking.status == 'completed') {
        continue;
      }
      final end = booking.scheduledEnd;
      if (end == null || end.isAfter(now)) return true;
    }
    return false;
  }

  Future<void> _deleteReferences(
    Iterable<DocumentReference<Object?>> references,
  ) async {
    final unique = <String, DocumentReference<Object?>>{
      for (final reference in references) reference.path: reference,
    }.values.toList(growable: false);

    const chunkSize = 400;
    for (var start = 0; start < unique.length; start += chunkSize) {
      final end = start + chunkSize > unique.length
          ? unique.length
          : start + chunkSize;
      final batch = _db.batch();
      for (final reference in unique.sublist(start, end)) {
        batch.delete(reference);
      }
      await batch.commit();
    }
  }

  void _validateBooking(CourtBooking booking) {
    if (booking.userId.isEmpty ||
        booking.venueId.isEmpty ||
        booking.courtId.isEmpty ||
        booking.dateKey.isEmpty) {
      throw ArgumentError('Thông tin đặt sân chưa đầy đủ.');
    }
    if (booking.startMinutes < 0 ||
        booking.endMinutes <= booking.startMinutes ||
        booking.durationMinutes % 30 != 0 ||
        booking.scheduledStart == null ||
        booking.scheduledEnd == null) {
      throw ArgumentError('Khung giờ đặt sân không hợp lệ.');
    }
    if (booking.participants < 1 || booking.totalPrice < 0) {
      throw ArgumentError('Số người chơi hoặc chi phí không hợp lệ.');
    }
  }

  int _readLockMinute(String documentId, Map<String, dynamic> data) {
    final raw = data['startMinutes'];
    if (raw is int) return raw;
    if (raw is num) return raw.round();
    return _minuteFromLockId(documentId);
  }

  int _minuteFromLockId(String documentId) {
    return int.tryParse(documentId.split('_').last) ?? 0;
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
