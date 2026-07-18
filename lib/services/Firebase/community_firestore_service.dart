import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../models/community_models.dart';

class AlreadyJoinedException implements Exception {
  const AlreadyJoinedException();
}

class CommunityCapacityException implements Exception {
  const CommunityCapacityException();
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
        .map((doc) => MatchmakingRoom.fromJson(doc.data(), fallbackId: doc.id))
        .toList();
    items.sort((a, b) => a.playAt.compareTo(b.playAt));
    return items;
    });
  }

  Stream<List<MatchmakingMember>> watchMembers(String roomId) {
    debugPrint('Matchmaking members query path: ${_members.path}, roomId: $roomId');
    return _members.where('roomId', isEqualTo: roomId).snapshots().map((snapshot) {
        final items = snapshot.docs
            .map(
              (doc) =>
                  MatchmakingMember.fromJson(doc.data(), fallbackId: doc.id),
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
    final roomRef = _rooms.doc();
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
    final batch = _db.batch();
    batch.set(roomRef, {
      ...savedRoom.toJson(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.set(_members.doc(memberId), {
      ...member.toJson(),
      'joinedAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
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
