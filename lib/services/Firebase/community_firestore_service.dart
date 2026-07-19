import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../models/community_models.dart';
import '../../models/court_booking.dart';

class AlreadyJoinedException implements Exception {
  const AlreadyJoinedException();
}

class CommunityCapacityException implements Exception {
  const CommunityCapacityException();
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
    await _db.runTransaction((transaction) async {
      debugPrint('Event ID: ${registration.eventId}');
      final eventSnapshot = await transaction.get(eventRef);
      final eventData = eventSnapshot.data();
      if (!eventSnapshot.exists || eventData == null) {
        throw StateError('Sự kiện không còn tồn tại.');
      }
      final existing = await transaction.get(registrationRef);
      if (existing.exists) throw const AlreadyJoinedException();
      final event = SportEvent.fromJson(
        eventData,
        fallbackId: eventSnapshot.id,
      );
      if (!event.active ||
          event.isFull ||
          event.startAt.isBefore(DateTime.now())) {
        throw const CommunityCapacityException();
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
        'joinedAt': FieldValue.serverTimestamp(),
      });
    });
    return savedRoom;
  }

  Future<void> joinRoom(MatchmakingMember member) async {
    final roomRef = _rooms.doc(member.roomId);
    final memberId = '${member.roomId}_${member.userId}';
    final memberRef = _members.doc(memberId);
    await _db.runTransaction((transaction) async {
      debugPrint('Matchmaking room ID: ${member.roomId}');
      final roomSnapshot = await transaction.get(roomRef);
      final roomData = roomSnapshot.data();
      if (!roomSnapshot.exists || roomData == null) {
        throw StateError('Phòng ghép không còn tồn tại.');
      }
      final existing = await transaction.get(memberRef);
      if (existing.exists) throw const AlreadyJoinedException();
      final room = MatchmakingRoom.fromJson(
        roomData,
        fallbackId: roomSnapshot.id,
      );
      if (!room.isOpen || room.isFull) {
        throw const CommunityCapacityException();
      }
      transaction.set(memberRef, {
        ...member.toJson(),
        '_id': memberId,
        'joinedAt': FieldValue.serverTimestamp(),
      });
      transaction.update(roomRef, {
        'memberCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
