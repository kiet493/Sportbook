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

  Future<SportEvent> createEvent({
    required SportEvent event,
    required UserModel creator,
  }) {
    if (event.title.trim().isEmpty || event.description.trim().isEmpty) {
      throw const CommunityValidationException(
        'Vui lòng nhập tên và mô tả sự kiện.',
      );
    }
    if (event.venueId.isEmpty || event.fieldId.isEmpty) {
      throw const CommunityValidationException(
        'Vui lòng chọn cụm sân và sân tổ chức.',
      );
    }
    final now = DateTime.now();
    final earliestDate = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(const Duration(days: 3));
    if (event.createdBy != creator.id ||
        event.dailyStartMinutes < 6 * 60 ||
        event.dailyEndMinutes > 23 * 60 ||
        event.dailyEndMinutes <= event.dailyStartMinutes ||
        event.startAt.isBefore(earliestDate) ||
        event.capacity < 2 ||
        event.status != 'pending_payment' ||
        event.paymentStatus != 'unpaid' ||
        event.estimatedPrice <= 0 ||
        event.totalDurationMinutes <= 0) {
      throw const CommunityValidationException(
        'Sự kiện phải bắt đầu sau hôm nay ít nhất 3 ngày và có thông tin thanh toán hợp lệ.',
      );
    }
    return _service.createEvent(event);
  }

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

  Future<void> reviewJoinRequest({
    required String roomId,
    required String userId,
    required bool approve,
  }) => _service.reviewJoinRequest(
    roomId: roomId,
    userId: userId,
    approve: approve,
  );
}
