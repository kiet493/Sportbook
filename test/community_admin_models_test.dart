import 'package:flutter_test/flutter_test.dart';
import 'package:sportbook/models/admin_content_models.dart';
import 'package:sportbook/models/community_models.dart';

void main() {
  test('event preserves capacity and registration state', () {
    final event = SportEvent.fromJson({
      '_id': 'event-1',
      'title': 'Giải cầu lông cuối tuần',
      'sport': 'Cầu lông',
      'location': 'SportBook Arena',
      'startAt': DateTime.now().add(const Duration(days: 2)),
      'endAt': DateTime.now().add(const Duration(days: 2, hours: 3)),
      'capacity': 16,
      'registeredCount': 16,
      'isActive': true,
    }, fallbackId: 'fallback');

    expect(event.id, 'event-1');
    expect(event.isFull, isTrue);
    expect(event.toJson()['registeredCount'], 16);
  });

  test('matchmaking room reports open slots', () {
    final room = MatchmakingRoom(
      id: 'room-1',
      title: 'Tìm đôi đánh cầu',
      sport: 'Cầu lông',
      venueName: 'Sân A',
      playAt: DateTime.now().add(const Duration(days: 1)),
      skillLevel: 'Trung bình',
      maxMembers: 4,
      memberCount: 2,
      createdBy: 'user-1',
      creatorName: 'An',
      description: '',
      status: 'open',
    );

    expect(room.isOpen, isTrue);
    expect(room.isFull, isFalse);
    expect(room.copyWith(memberCount: 4).isFull, isTrue);
  });

  test('admin inventory model round-trips Firebase fields', () {
    const item = InventoryItem(
      id: 'equipment-1',
      name: 'Vợt cầu lông',
      description: 'Vợt cho thuê',
      quantity: 12,
      unit: 'cái',
      price: 30000,
      active: true,
    );

    final decoded = InventoryItem.fromJson(
      item.toJson(),
      fallbackId: 'fallback',
    );
    expect(decoded.id, item.id);
    expect(decoded.quantity, 12);
    expect(decoded.price, 30000);
    expect(decoded.active, isTrue);
  });
}
