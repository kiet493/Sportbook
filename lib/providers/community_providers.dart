import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/community_models.dart';
import '../models/user_model.dart';
import '../repositories/community_repository.dart';
import '../services/Firebase/community_firestore_service.dart';
import 'firebase_providers.dart';
import 'registration_providers.dart';

final communityServiceProvider = Provider<CommunityFirestoreService>((ref) {
  return CommunityFirestoreService();
});

final communityRepositoryProvider = Provider<CommunityRepository>((ref) {
  return CommunityRepository(ref.watch(communityServiceProvider));
});

final eventsProvider = StreamProvider<List<SportEvent>>((ref) {
  final auth = ref.watch(firebaseAuthStateProvider);
  if (auth.isLoading) return const Stream<List<SportEvent>>.empty();
  if (auth.hasError) return Stream.error(auth.error!, auth.stackTrace);
  if (auth.valueOrNull == null) {
    return Stream.error(const FirebaseAuthRequiredException());
  }
  return ref.watch(communityRepositoryProvider).watchEvents();
});

final matchmakingRoomsProvider = StreamProvider<List<MatchmakingRoom>>((ref) {
  final auth = ref.watch(firebaseAuthStateProvider);
  if (auth.isLoading) return const Stream<List<MatchmakingRoom>>.empty();
  if (auth.hasError) return Stream.error(auth.error!, auth.stackTrace);
  if (auth.valueOrNull == null) {
    return Stream.error(const FirebaseAuthRequiredException());
  }
  return ref.watch(communityRepositoryProvider).watchRooms();
});

final matchmakingMembersProvider =
    StreamProvider.family<List<MatchmakingMember>, String>((ref, roomId) {
      final auth = ref.watch(firebaseAuthStateProvider);
      if (auth.isLoading) return const Stream<List<MatchmakingMember>>.empty();
      if (auth.hasError) return Stream.error(auth.error!, auth.stackTrace);
      if (auth.valueOrNull == null) {
        return Stream.error(const FirebaseAuthRequiredException());
      }
      return ref.watch(communityRepositoryProvider).watchMembers(roomId);
    });

class CommunityActionNotifier extends AsyncNotifier<void> {
  @override
  void build() {}

  Future<String?> registerEvent(SportEvent event) {
    final user = _authenticatedSessionUser();
    if (user == null) {
      return Future.value(
        'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
      );
    }
    return _execute(
      () => ref.read(communityRepositoryProvider).registerEvent(event, user),
    );
  }

  Future<String?> joinRoom(MatchmakingRoom room) {
    final user = _authenticatedSessionUser();
    if (user == null) {
      return Future.value(
        'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
      );
    }
    return _execute(
      () => ref.read(communityRepositoryProvider).joinRoom(room, user),
    );
  }

  Future<String?> reviewJoinRequest({
    required String roomId,
    required String userId,
    required bool approve,
  }) => _execute(
    () => ref
        .read(communityRepositoryProvider)
        .reviewJoinRequest(roomId: roomId, userId: userId, approve: approve),
  );

  UserModel? _authenticatedSessionUser() {
    final user = ref.read(sessionProvider)?.user;
    final firebaseUser = ref.read(firebaseAuthStateProvider).valueOrNull;
    if (user == null || firebaseUser == null || user.id != firebaseUser.uid) {
      return null;
    }
    return user;
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
      return 'Sự kiện/phòng đã đầy hoặc đã kết thúc.';
    } on CommunityValidationException catch (error) {
      state = const AsyncData(null);
      return error.message;
    } on FirebaseException catch (error, stackTrace) {
      debugPrint('Firestore error code: ${error.code}');
      debugPrint('Firestore error message: ${error.message}');
      debugPrintStack(stackTrace: stackTrace);
      state = AsyncError(error, stackTrace);
      return communityFirestoreErrorMessage(error);
    } catch (error, stackTrace) {
      debugPrint('Community action error: $error');
      debugPrintStack(stackTrace: stackTrace);
      state = AsyncError(error, stackTrace);
      return 'Không thể thực hiện thao tác lúc này.';
    }
  }
}

final communityActionProvider =
    AsyncNotifierProvider<CommunityActionNotifier, void>(
      CommunityActionNotifier.new,
    );

class CreateEventNotifier extends AsyncNotifier<SportEvent?> {
  @override
  SportEvent? build() => null;

  Future<String?> create(SportEvent event) async {
    final user = ref.read(sessionProvider)?.user;
    final firebaseUser = ref.read(firebaseAuthStateProvider).valueOrNull;
    if (user == null || firebaseUser == null || user.id != firebaseUser.uid) {
      return 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';
    }
    state = const AsyncLoading();
    try {
      final saved = await ref
          .read(communityRepositoryProvider)
          .createEvent(event: event, creator: user);
      state = AsyncData(saved);
      ref.invalidate(eventsProvider);
      return null;
    } on CommunityValidationException catch (error) {
      state = const AsyncData(null);
      return error.message;
    } on EventSlotUnavailableException {
      state = const AsyncData(null);
      return 'Một hoặc nhiều khung giờ đã có người đặt hoặc đang bảo trì.';
    } on FirebaseException catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return communityFirestoreErrorMessage(error);
    } catch (error, stackTrace) {
      debugPrint('Create event error: $error');
      debugPrintStack(stackTrace: stackTrace);
      state = AsyncError(error, stackTrace);
      return error is StateError
          ? error.message.toString()
          : 'Không thể tạo sự kiện lúc này.';
    }
  }
}

final createEventProvider =
    AsyncNotifierProvider<CreateEventNotifier, SportEvent?>(
      CreateEventNotifier.new,
    );

class CreateMatchmakingNotifier extends AsyncNotifier<MatchmakingRoom?> {
  @override
  MatchmakingRoom? build() => null;

  Future<String?> create(MatchmakingRoom room) async {
    final user = ref.read(sessionProvider)?.user;
    final firebaseUser = ref.read(firebaseAuthStateProvider).valueOrNull;
    if (user == null || firebaseUser == null || user.id != firebaseUser.uid) {
      return 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';
    }

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
    } on MatchmakingBookingRequiredException catch (error) {
      state = const AsyncData(null);
      return error.message;
    } on FirebaseException catch (error, stackTrace) {
      debugPrint('Firestore error code: ${error.code}');
      debugPrint('Firestore error message: ${error.message}');
      debugPrintStack(stackTrace: stackTrace);
      state = AsyncError(error, stackTrace);
      return communityFirestoreErrorMessage(error);
    } catch (error, stackTrace) {
      debugPrint('Create matchmaking error: $error');
      debugPrintStack(stackTrace: stackTrace);
      state = AsyncError(error, stackTrace);
      return 'Không thể tạo phòng ghép lúc này.';
    }
  }
}

final createMatchmakingProvider =
    AsyncNotifierProvider<CreateMatchmakingNotifier, MatchmakingRoom?>(
      CreateMatchmakingNotifier.new,
    );

String communityFirestoreErrorMessage(FirebaseException error) =>
    switch (error.code) {
      'permission-denied' => 'Bạn không có quyền thực hiện thao tác này.',
      'unauthenticated' =>
        'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
      'unavailable' => 'Không thể kết nối Firebase. Vui lòng thử lại.',
      'not-found' => 'Dữ liệu không còn tồn tại.',
      _ => error.message ?? 'Firebase gặp lỗi (${error.code}).',
    };
