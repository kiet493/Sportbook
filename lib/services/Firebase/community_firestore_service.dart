import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../models/community_models.dart';
import '../../models/court_booking.dart';
import 'notification_firestore_service.dart';

class AlreadyJoinedException implements Exception {
  const AlreadyJoinedException();
}

class CommunityCapacityException implements Exception {
  const CommunityCapacityException();
}

class EventSlotUnavailableException implements Exception {
  const EventSlotUnavailableException();
}

class MatchmakingBookingRequiredException implements Exception {
  final String message;

  const MatchmakingBookingRequiredException(this.message);

  @override
  String toString() => message;
}

class CommunityFirestoreService {
  CommunityFirestoreService({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _events =>
      _db.collection('events');
  CollectionReference<Map<String, dynamic>> get _registrations =>
      _db.collection('event_registrations');
  CollectionReference<Map<String, dynamic>> get _rooms =>
      _db.collection('matchmaking_rooms');
  CollectionReference<Map<String, dynamic>> get _members =>
      _db.collection('matchmaking_members');
  CollectionReference<Map<String, dynamic>> get _slotLocks =>
      _db.collection('bookingSlotLocks');

  Future<SportEvent> createEvent(SportEvent event) async {
    final eventRef = _events.doc();
    final saved = event.copyWith(id: eventRef.id);
    final firstDay = DateTime(
      saved.startAt.year,
      saved.startAt.month,
      saved.startAt.day,
    );
    final lastDay = DateTime(
      saved.endAt.year,
      saved.endAt.month,
      saved.endAt.day,
    );
    final dayCount = lastDay.difference(firstDay).inDays + 1;
    final slotCountPerDay =
        (saved.dailyEndMinutes - saved.dailyStartMinutes) ~/ 30;
    if (dayCount < 1 || slotCountPerDay < 1) {
      throw StateError('Ngày hoặc khung giờ sự kiện không hợp lệ.');
    }
    if (dayCount * slotCountPerDay > 450) {
      throw StateError(
        'Sự kiện chọn quá nhiều ô giờ. Vui lòng rút ngắn số ngày hoặc thời lượng mỗi ngày.',
      );
    }

    final lockRefs = <DocumentReference<Map<String, dynamic>>>[];
    final lockData = <Map<String, dynamic>>[];
    for (var dayOffset = 0; dayOffset < dayCount; dayOffset++) {
      final selectedDate = firstDay.add(Duration(days: dayOffset));
      final selectedDateKey = dateKey(selectedDate);
      for (
        var minute = saved.dailyStartMinutes;
        minute < saved.dailyEndMinutes;
        minute += 30
      ) {
        lockRefs.add(
          _slotLocks.doc(
            '${saved.venueId}_${selectedDateKey}_${saved.fieldId}_$minute',
          ),
        );
        lockData.add({
          'bookingId': '',
          'eventId': eventRef.id,
          'venueId': saved.venueId,
          'fieldId': saved.fieldId,
          'courtId': saved.fieldId,
          'dateKey': selectedDateKey,
          'startMinutes': minute,
          'status': CourtSlotStatus.event,
          'userId': saved.createdBy,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }

    final venueRef = _db.collection('fieldComplexes').doc(saved.venueId);
    final courtRef = _db.collection('sportFields').doc(saved.fieldId);
    await _db.runTransaction((transaction) async {
      final venueSnapshot = await transaction.get(venueRef);
      final courtSnapshot = await transaction.get(courtRef);
      final venueData = venueSnapshot.data();
      final courtData = courtSnapshot.data();
      if (!venueSnapshot.exists ||
          venueData == null ||
          !courtSnapshot.exists ||
          courtData == null) {
        throw StateError('Không tìm thấy cụm sân hoặc sân đã chọn.');
      }
      final court = SportCourt.fromJson(
        courtData,
        fallbackId: courtSnapshot.id,
      );
      if (!court.active || court.venueId != saved.venueId) {
        throw StateError(
          'Sân đã chọn không hoạt động hoặc không thuộc cụm sân.',
        );
      }
      for (final lockRef in lockRefs) {
        final lockSnapshot = await transaction.get(lockRef);
        if (lockSnapshot.exists) {
          throw const EventSlotUnavailableException();
        }
      }
      transaction.set(eventRef, {
        ...saved.toJson(),
        'startAt': Timestamp.fromDate(saved.startAt),
        'endAt': Timestamp.fromDate(saved.endAt),
        'deadline': Timestamp.fromDate(saved.deadline),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      for (var index = 0; index < lockRefs.length; index++) {
        transaction.set(lockRefs[index], lockData[index]);
      }
    });
    return saved;
  }

  Stream<List<SportEvent>> watchEvents() {
    debugPrint('Event query path: ${_events.path}');
    return _events.snapshots().map((snapshot) {
      final now = DateTime.now();
      final items = snapshot.docs
          .map((doc) => SportEvent.fromJson(doc.data(), fallbackId: doc.id))
          .where((event) => event.active && event.endAt.isAfter(now))
          .toList();
      items.sort((a, b) => a.startAt.compareTo(b.startAt));
      return items;
    });
  }

  Stream<List<MatchmakingRoom>> watchRooms() {
    debugPrint('Matchmaking query path: ${_rooms.path}');
    return _rooms.snapshots().map((snapshot) {
      final items = snapshot.docs
          .map(
            (doc) => MatchmakingRoom.fromJson(doc.data(), fallbackId: doc.id),
          )
          .toList();
      items.sort((a, b) => a.playAt.compareTo(b.playAt));
      return items;
    });
  }

  Stream<List<MatchmakingMember>> watchMembers(String roomId) {
    debugPrint(
      'Matchmaking members query path: ${_members.path}, roomId: $roomId',
    );
    return _members.where('roomId', isEqualTo: roomId).snapshots().map((
      snapshot,
    ) {
      final items = snapshot.docs
          .map(
            (doc) => MatchmakingMember.fromJson(doc.data(), fallbackId: doc.id),
          )
          .toList();
      items.sort((a, b) => a.joinedAt.compareTo(b.joinedAt));
      return items;
    });
  }

  Future<void> registerEvent(EventRegistration registration) async {
    final registrationId = '${registration.eventId}_${registration.userId}';
    final eventRef = _events.doc(registration.eventId);
    final registrationRef = _registrations.doc(registrationId);

    // Firestore Web SDK (JS interop) không thể truyền custom Dart exceptions
    // qua ranh giới Promise. Dùng biến flag bên ngoài để capture lỗi,
    // rồi throw SAU KHI transaction hoàn thành.
    Object? _txError;

    await _db.runTransaction((transaction) async {
      debugPrint('Event ID: ${registration.eventId}');
      _txError = null;

      // Đọc tất cả documents song song trước khi thực hiện bất kỳ write nào.
      final results = await Future.wait([
        transaction.get(eventRef),
        transaction.get(registrationRef),
      ]);
      final eventSnapshot = results[0];
      final existingSnapshot = results[1];

      final eventData = eventSnapshot.data();
      if (!eventSnapshot.exists || eventData == null) {
        _txError = StateError('Sự kiện không còn tồn tại.');
        return;
      }
      if (existingSnapshot.exists) {
        _txError = const AlreadyJoinedException();
        return;
      }

      final event = SportEvent.fromJson(
        eventData,
        fallbackId: eventSnapshot.id,
      );
      if (!event.active ||
          event.isFull ||
          event.endAt.isBefore(DateTime.now())) {
        _txError = const CommunityCapacityException();
        return;
      }

      transaction.set(registrationRef, {
        ...registration.toJson(),
        '_id': registrationId,
        'registeredAt': FieldValue.serverTimestamp(),
      });
      transaction.update(eventRef, {
        'registeredCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });

    // Throw sau khi transaction kết thúc — an toàn với JS interop.
    final err = _txError;
    if (err != null) throw err;
  }

  Future<MatchmakingRoom> createRoom(
    MatchmakingRoom room,
    MatchmakingMember creator,
  ) async {
    if (room.bookingId.isEmpty) {
      throw const MatchmakingBookingRequiredException(
        'Bạn phải chọn một lịch đặt sân hợp lệ.',
      );
    }
    final roomRef = _rooms.doc();
    final bookingRef = _db.collection('bookings').doc(room.bookingId);
    final savedRoom = room.copyWith(id: roomRef.id, memberCount: 1);
    final memberId = '${roomRef.id}_${creator.userId}';
    final member = MatchmakingMember(
      id: memberId,
      roomId: roomRef.id,
      userId: creator.userId,
      userName: creator.userName,
      phone: creator.phone,
      joinedAt: creator.joinedAt,
    );
    await _db.runTransaction((transaction) async {
      final bookingSnapshot = await transaction.get(bookingRef);
      final bookingData = bookingSnapshot.data();
      if (!bookingSnapshot.exists || bookingData == null) {
        throw const MatchmakingBookingRequiredException(
          'Không tìm thấy lịch đặt sân đã chọn.',
        );
      }

      final booking = CourtBooking.fromJson(
        bookingData,
        fallbackId: bookingSnapshot.id,
      );
      final scheduledStart = booking.scheduledStart;
      final scheduledEnd = booking.scheduledEnd;
      final matchesBooking =
          booking.userId == creator.userId &&
          booking.status == CourtSlotStatus.booked &&
          scheduledStart != null &&
          scheduledEnd != null &&
          scheduledStart.isAfter(DateTime.now()) &&
          booking.venueId == room.venueId &&
          booking.courtId == room.courtId &&
          booking.venueName == room.venueName &&
          booking.courtName == room.courtName &&
          scheduledStart.difference(room.playAt).abs() <
              const Duration(minutes: 1);
      if (!matchesBooking) {
        throw const MatchmakingBookingRequiredException(
          'Lịch đặt sân không hợp lệ hoặc không thuộc tài khoản của bạn.',
        );
      }

      transaction.set(roomRef, {
        ...savedRoom.toJson(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      transaction.set(_members.doc(memberId), {
        ...member.toJson(),
        'status': 'approved',
        'joinedAt': FieldValue.serverTimestamp(),
      });
    });
    return savedRoom;
  }

  Future<void> joinRoom(MatchmakingMember member) async {
    final roomRef = _rooms.doc(member.roomId);
    final memberId = '${member.roomId}_${member.userId}';
    final memberRef = _members.doc(memberId);

    // Firestore Web SDK (JS interop) không thể truyền custom Dart exceptions
    // qua ranh giới Promise. Dùng biến flag bên ngoài để capture lỗi.
    Object? _txError;

    await _db.runTransaction((transaction) async {
      debugPrint('Matchmaking room ID: ${member.roomId}');
      _txError = null;

      // Đọc tất cả documents song song trước khi thực hiện bất kỳ write nào.
      final results = await Future.wait([
        transaction.get(roomRef),
        transaction.get(memberRef),
      ]);
      final roomSnapshot = results[0];
      final existingSnapshot = results[1];

      final roomData = roomSnapshot.data();
      if (!roomSnapshot.exists || roomData == null) {
        _txError = StateError('Phòng ghép không còn tồn tại.');
        return;
      }
      if (existingSnapshot.exists) {
        _txError = const AlreadyJoinedException();
        return;
      }
      final room = MatchmakingRoom.fromJson(
        roomData,
        fallbackId: roomSnapshot.id,
      );
      if (!room.isOpen || room.isFull) {
        _txError = const CommunityCapacityException();
        return;
      }

      transaction.set(memberRef, {
        ...member.toJson(),
        '_id': memberId,
        'status': 'pending',
        'joinedAt': FieldValue.serverTimestamp(),
      });
    });

    // Throw sau khi transaction kết thúc — an toàn với JS interop.
    final err = _txError;
    if (err != null) throw err;
  }

  Future<void> reviewJoinRequest({
    required String roomId,
    required String userId,
    required bool approve,
  }) async {
    final roomRef = _rooms.doc(roomId);
    final memberRef = _members.doc('${roomId}_$userId');
    await _db.runTransaction((transaction) async {
      final roomSnapshot = await transaction.get(roomRef);
      final memberSnapshot = await transaction.get(memberRef);
      final roomData = roomSnapshot.data();
      final memberData = memberSnapshot.data();
      if (!roomSnapshot.exists ||
          !memberSnapshot.exists ||
          roomData == null ||
          memberData == null) {
        throw StateError('Yêu cầu ghép đội không còn tồn tại.');
      }
      final room = MatchmakingRoom.fromJson(roomData, fallbackId: roomId);
      if (memberData['status'] != 'pending') return;
      if (approve && (!room.isOpen || room.isFull)) {
        throw const CommunityCapacityException();
      }
      transaction.update(memberRef, {
        'status': approve ? 'approved' : 'rejected',
        'reviewedAt': FieldValue.serverTimestamp(),
      });
      if (approve) {
        transaction.update(roomRef, {
          'memberCount': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
    final member = await memberRef.get();
    final memberData = member.data();
    if (memberData != null) {
      await NotificationFirestoreService(firestore: _db).create(
        userId: userId,
        title: approve
            ? 'Đã được chấp nhận vào phòng ghép'
            : 'Yêu cầu ghép đội bị từ chối',
        body: approve
            ? 'Chủ sân đã duyệt yêu cầu tham gia phòng ghép của bạn.'
            : 'Chủ sân đã từ chối yêu cầu tham gia phòng ghép của bạn.',
        type: 'matchmaking',
      );
    }
  }
}
