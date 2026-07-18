import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/community_models.dart';
import '../repositories/community_repository.dart';
import '../services/Firebase/community_firestore_service.dart';
import 'registration_providers.dart';

final communityServiceProvider = Provider<CommunityFirestoreService>((ref) {
  return CommunityFirestoreService();
});

final communityRepositoryProvider = Provider<CommunityRepository>((ref) {
  return CommunityRepository(ref.watch(communityServiceProvider));
});

final eventsProvider = StreamProvider<List<SportEvent>>((ref) {
  return ref.watch(communityRepositoryProvider).watchEvents();
});

final matchmakingRoomsProvider = StreamProvider<List<MatchmakingRoom>>((ref) {
  return ref.watch(communityRepositoryProvider).watchRooms();
});

final matchmakingMembersProvider =
    StreamProvider.family<List<MatchmakingMember>, String>((ref, roomId) {
      return ref.watch(communityRepositoryProvider).watchMembers(roomId);
    });

class CommunityActionNotifier extends AsyncNotifier<void> {
  @override
  void build() {}

  Future<String?> registerEvent(SportEvent event) async {
    final user = ref.read(sessionProvider)?.user;
    if (user == null) return 'Bạn cần đăng nhập để đăng ký.';
    return _execute(
      () => ref.read(communityRepositoryProvider).registerEvent(event, user),
    );
  }

  Future<String?> joinRoom(MatchmakingRoom room) async {
    final user = ref.read(sessionProvider)?.user;
    if (user == null) return 'Bạn cần đăng nhập để tham gia.';
    return _execute(
      () => ref.read(communityRepositoryProvider).joinRoom(room, user),
    );
  }

  Future<String?> _execute(Future<void> Function() action) async {
    state = const AsyncLoading();
    try {
      await action();
      state = const AsyncData(null);
      ref.invalidate(eventsProvider);
      ref.invalidate(matchmakingRoomsProvider);
      ref.invalidate(matchmakingMembersProvider);
      return null;
    } on AlreadyJoinedException {
      state = const AsyncData(null);
      return 'Bạn đã tham gia trước đó.';
    } on CommunityCapacityException {
      state = const AsyncData(null);
      return 'Đã hết chỗ hoặc thời gian tham gia đã kết thúc.';
    } on CommunityValidationException catch (error) {
      state = const AsyncData(null);
      return error.message;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return 'Không thể thực hiện thao tác lúc này.';
    }
  }
}

final communityActionProvider =
    AsyncNotifierProvider<CommunityActionNotifier, void>(
      CommunityActionNotifier.new,
    );

class CreateMatchmakingNotifier extends AsyncNotifier<MatchmakingRoom?> {
  @override
  MatchmakingRoom? build() => null;

  Future<String?> create(MatchmakingRoom room) async {
    final user = ref.read(sessionProvider)?.user;
    if (user == null) return 'Bạn cần đăng nhập để tạo phòng.';
    state = const AsyncLoading();
    try {
      final saved = await ref
          .read(communityRepositoryProvider)
          .createRoom(room: room, creator: user);
      state = AsyncData(saved);
      ref.invalidate(matchmakingRoomsProvider);
      return null;
    } on CommunityValidationException catch (error) {
      state = const AsyncData(null);
      return error.message;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return 'Không thể tạo phòng ghép lúc này.';
    }
  }
}

final createMatchmakingProvider =
    AsyncNotifierProvider<CreateMatchmakingNotifier, MatchmakingRoom?>(
      CreateMatchmakingNotifier.new,
    );
