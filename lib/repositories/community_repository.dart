import '../models/community_models.dart';
import '../models/user_model.dart';
import '../services/Firebase/community_firestore_service.dart';

class CommunityValidationException implements Exception {
  final String message;
  const CommunityValidationException(this.message);
}

class CommunityRepository {
  CommunityRepository(this._service);

  final CommunityFirestoreService _service;

  Stream<List<SportEvent>> watchEvents() => _service.watchEvents();
  Stream<List<MatchmakingRoom>> watchRooms() => _service.watchRooms();
  Stream<List<MatchmakingMember>> watchMembers(String roomId) =>
      _service.watchMembers(roomId);

  Future<void> registerEvent(SportEvent event, UserModel user) {
    if (event.id.isEmpty || user.id.isEmpty) {
      throw const CommunityValidationException('Thiếu thông tin đăng ký.');
    }
    return _service.registerEvent(
      EventRegistration(
        id: '',
        eventId: event.id,
        userId: user.id,
        userName: user.fullName,
        phone: user.phone,
        status: 'registered',
        registeredAt: DateTime.now(),
      ),
    );
  }

  Future<MatchmakingRoom> createRoom({
    required MatchmakingRoom room,
    required UserModel creator,
  }) {
    if (room.bookingId.isEmpty ||
        room.venueId.isEmpty ||
        room.courtId.isEmpty) {
      throw const CommunityValidationException(
        'Bạn phải chọn sân và khung giờ từ lịch đã đặt.',
      );
    }
    if (room.title.trim().isEmpty || room.venueName.trim().isEmpty) {
      throw const CommunityValidationException(
        'Tên phòng và địa điểm không được để trống.',
      );
    }
    if (room.playAt.isBefore(DateTime.now()) || room.maxMembers < 2) {
      throw const CommunityValidationException(
        'Thời gian hoặc số lượng thành viên không hợp lệ.',
      );
    }
    return _service.createRoom(
      room,
      MatchmakingMember(
        id: '',
        roomId: '',
        userId: creator.id,
        userName: creator.fullName,
        phone: creator.phone,
        joinedAt: DateTime.now(),
      ),
    );
  }

  Future<void> joinRoom(MatchmakingRoom room, UserModel user) =>
      _service.joinRoom(
        MatchmakingMember(
          id: '',
          roomId: room.id,
          userId: user.id,
          userName: user.fullName,
          phone: user.phone,
          joinedAt: DateTime.now(),
        ),
      );
}
