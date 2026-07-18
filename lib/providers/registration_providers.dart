import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import '../repositories/user_repository.dart';
import '../services/Firebase/firebase_auth_service.dart';
import '../services/Firebase/storage_service.dart';
import 'firebase_providers.dart';
import 'manage_users_providers.dart';

final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService();
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

class SessionUser {
  final UserModel user;
  const SessionUser(this.user);
}

class SessionNotifier extends Notifier<SessionUser?> {
  @override
  SessionUser? build() => null;

  void setUser(UserModel user) => state = SessionUser(user);
  void clear() => state = null;
}

final sessionProvider = NotifierProvider<SessionNotifier, SessionUser?>(
  SessionNotifier.new,
);

class RegistrationResult {
  final bool success;
  final UserModel? user;
  final String? fieldError;
  final String? message;

  const RegistrationResult.success(this.user)
    : success = true,
      fieldError = null,
      message = null;

  const RegistrationResult.fieldError(this.fieldError, this.message)
    : success = false,
      user = null;

  const RegistrationResult.error(this.message)
    : success = false,
      fieldError = null,
      user = null;
}

class RegistrationNotifier extends AsyncNotifier<void> {
  @override
  void build() {}

  Future<RegistrationResult> submit({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    state = const AsyncLoading();

    final startupError = ref.read(firebaseStartupErrorProvider);
    if (startupError != null) {
      state = const AsyncData(null);
      return RegistrationResult.error(startupError);
    }

    final repo = ref.read(userRepositoryProvider);
    final auth = ref.read(firebaseAuthServiceProvider);
    UserCredential? credential;

    try {
      credential = await auth.createUser(email: email, password: password);
      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        state = const AsyncData(null);
        return const RegistrationResult.error(
          'Không tạo được tài khoản Firebase',
        );
      }

      await auth.updateDisplayName(fullName.trim());

      final user = UserModel.newUser(
        id: firebaseUser.uid,
        fullName: fullName,
        email: email,
        phone: phone,
        role: UserRole.user,
        gender: UserGender.other,
      );
      final created = await repo.createUser(
        user,
        ensureUnique: false,
        verifyProfileWrite: false,
      );

      try {
        await auth.signOut();
      } catch (_) {
        // The profile has already been written; login can replace the session.
      }
      ref.read(sessionProvider.notifier).clear();
      state = const AsyncData(null);
      return RegistrationResult.success(created);
    } on FirebaseAuthException catch (e) {
      await _rollbackRegistration(repo, auth, credential);
      state = const AsyncData(null);
      return _registrationErrorFromAuth(e);
    } on UserValidationException catch (e) {
      await _rollbackRegistration(repo, auth, credential);
      state = const AsyncData(null);
      return RegistrationResult.fieldError(e.code, e.message);
    } on FirebaseException catch (e) {
      await _rollbackRegistration(repo, auth, credential);
      state = AsyncError(e, StackTrace.current);
      return RegistrationResult.error(_firestoreMessage(e));
    } catch (e, st) {
      await _rollbackRegistration(repo, auth, credential);
      state = AsyncError(e, st);
      return RegistrationResult.error(e.toString());
    }
  }
}

final registrationProvider = AsyncNotifierProvider<RegistrationNotifier, void>(
  RegistrationNotifier.new,
);

class LoginNotifier extends AsyncNotifier<bool> {
  @override
  bool build() => false;

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();

    final startupError = ref.read(firebaseStartupErrorProvider);
    if (startupError != null) {
      state = const AsyncData(false);
      return startupError;
    }

    try {
      final auth = ref.read(firebaseAuthServiceProvider);
      final credential = await auth.signIn(email: email, password: password);
      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        state = const AsyncData(false);
        return 'Không tìm thấy phiên đăng nhập Firebase';
      }

      final profile = await _ensureProfileForSignedInUser(
        repo: ref.read(userRepositoryProvider),
        firebaseUser: firebaseUser,
        fallbackEmail: email,
      );

      if (profile.id != firebaseUser.uid) {
        await auth.signOut();
        state = const AsyncData(false);
        return 'Hồ sơ người dùng không khớp Firebase UID';
      }

      if (profile.isBanned) {
        await auth.signOut();
        state = const AsyncData(false);
        return 'Tài khoản của bạn đã bị khóa';
      }

      ref.read(sessionProvider.notifier).setUser(profile);
      state = const AsyncData(true);
      return null;
    } on FirebaseAuthException catch (e) {
      state = const AsyncData(false);
      return _loginMessageFromAuth(e);
    } on FirebaseException catch (e, st) {
      state = AsyncError(e, st);
      return _firestoreMessage(e);
    } catch (e, st) {
      state = AsyncError(e, st);
      return 'Đăng nhập thất bại, vui lòng thử lại';
    }
  }

  Future<void> logout() async {
    try {
      await ref.read(firebaseAuthServiceProvider).signOut();
    } catch (_) {
      // Local session must still be cleared even if Firebase is unavailable.
    } finally {
      ref.read(sessionProvider.notifier).clear();
      state = const AsyncData(false);
    }
  }

  Future<String?> sendPasswordReset(String email) async {
    final startupError = ref.read(firebaseStartupErrorProvider);
    if (startupError != null) return startupError;
    try {
      await ref.read(firebaseAuthServiceProvider).sendPasswordResetEmail(email);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') return 'Email không hợp lệ';
      if (e.code == 'too-many-requests') {
        return 'Bạn thao tác quá nhiều lần, vui lòng thử lại sau';
      }
      return e.message ?? 'Không thể gửi email đặt lại mật khẩu';
    } catch (_) {
      return 'Không thể gửi email đặt lại mật khẩu';
    }
  }
}

final loginProvider = AsyncNotifierProvider<LoginNotifier, bool>(
  LoginNotifier.new,
);

class ProfileNotifier extends AsyncNotifier<void> {
  @override
  void build() {}

  Future<String?> updateProfile({
    required String fullName,
    required String phone,
    required String gender,
    required String address,
    DateTime? dateOfBirth,
    String? avatarUrl,
  }) async {
    final session = ref.read(sessionProvider);
    if (session == null) return 'Bạn cần đăng nhập để cập nhật hồ sơ.';

    state = const AsyncLoading();
    try {
      final current = session.user;
      final updated = current.copyWith(
        fullName: fullName,
        phone: phone,
        gender: gender,
        address: address,
        dateOfBirth: dateOfBirth,
        clearDateOfBirth: dateOfBirth == null,
        avatarUrl: avatarUrl,
      );
      final saved = await ref
          .read(userRepositoryProvider)
          .saveAuthenticatedUserProfile(updated);
      try {
        final auth = ref.read(firebaseAuthServiceProvider);
        await auth.updateDisplayName(saved.fullName);
        if (avatarUrl != null && avatarUrl.isNotEmpty) {
          await auth.updatePhotoUrl(avatarUrl);
        }
      } catch (_) {
        // Firestore is the profile source of truth. Auth metadata is best-effort.
      }
      ref.read(sessionProvider.notifier).setUser(saved);
      state = const AsyncData(null);
      return null;
    } on UserValidationException catch (error) {
      state = const AsyncData(null);
      return error.message;
    } on FirebaseException catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return _firestoreMessage(error);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return 'Không thể cập nhật hồ sơ lúc này.';
    }
  }

  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final session = ref.read(sessionProvider);
    if (session == null) return 'Bạn cần đăng nhập để đổi mật khẩu.';

    state = const AsyncLoading();
    try {
      final auth = ref.read(firebaseAuthServiceProvider);
      await auth.reauthenticate(
        email: session.user.email,
        password: currentPassword,
      );
      await auth.updatePassword(newPassword);
      state = const AsyncData(null);
      return null;
    } on FirebaseAuthException catch (error) {
      state = const AsyncData(null);
      return switch (error.code) {
        'wrong-password' ||
        'invalid-credential' => 'Mật khẩu hiện tại không đúng.',
        'weak-password' => 'Mật khẩu mới chưa đủ mạnh.',
        'requires-recent-login' =>
          'Phiên đăng nhập đã cũ, vui lòng đăng nhập lại.',
        _ => error.message ?? 'Không thể đổi mật khẩu.',
      };
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return 'Không thể đổi mật khẩu lúc này.';
    }
  }
}

final profileProvider = AsyncNotifierProvider<ProfileNotifier, void>(
  ProfileNotifier.new,
);

Future<UserModel> _ensureProfileForSignedInUser({
  required UserRepository repo,
  required User firebaseUser,
  required String fallbackEmail,
}) async {
  final existing = await repo.fetch(firebaseUser.uid);
  if (existing != null) {
    if (existing.id == firebaseUser.uid) return existing;

    final corrected = existing.copyWith(id: firebaseUser.uid);
    return repo.saveAuthenticatedUserProfile(corrected);
  }

  final generatedProfile = _profileFromFirebaseUser(
    firebaseUser: firebaseUser,
    fallbackEmail: fallbackEmail,
  );

  return repo.createUser(
    generatedProfile,
    ensureUnique: false,
    verifyProfileWrite: false,
  );
}

UserModel _profileFromFirebaseUser({
  required User firebaseUser,
  required String fallbackEmail,
}) {
  final email = (firebaseUser.email ?? fallbackEmail).trim().toLowerCase();
  final displayName = firebaseUser.displayName?.trim();

  return UserModel.newUser(
    id: firebaseUser.uid,
    fullName: displayName == null || displayName.isEmpty
        ? email.split('@').first
        : displayName,
    email: email,
    phone: firebaseUser.phoneNumber ?? _fallbackPhoneForUid(firebaseUser.uid),
  );
}

String _firestoreMessage(FirebaseException e) {
  if (e.code == 'permission-denied') {
    return 'Firestore chưa cấp quyền đọc/ghi users. Hãy cập nhật Firestore Rules.';
  }
  return e.message ?? 'Firebase gặp lỗi (${e.code})';
}

RegistrationResult _registrationErrorFromAuth(FirebaseAuthException e) {
  switch (e.code) {
    case 'email-already-in-use':
      return const RegistrationResult.fieldError(
        'email',
        'Email đã được sử dụng',
      );
    case 'invalid-email':
      return const RegistrationResult.fieldError('email', 'Email không hợp lệ');
    case 'weak-password':
      return const RegistrationResult.fieldError(
        'password',
        'Mật khẩu quá yếu',
      );
    case 'operation-not-allowed':
      return const RegistrationResult.error(
        'Firebase Auth chưa bật phương thức Email/Password',
      );
    default:
      return RegistrationResult.error(
        e.message ?? 'Không thể tạo tài khoản (${e.code})',
      );
  }
}

String _loginMessageFromAuth(FirebaseAuthException e) {
  switch (e.code) {
    case 'invalid-email':
      return 'Email không hợp lệ';
    case 'user-disabled':
      return 'Tài khoản đã bị vô hiệu hóa';
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
      return 'Email hoặc mật khẩu không đúng';
    case 'too-many-requests':
      return 'Bạn thử quá nhiều lần, vui lòng thử lại sau';
    case 'operation-not-allowed':
      return 'Firebase Auth chưa bật phương thức Email/Password';
    default:
      return e.message ?? 'Đăng nhập thất bại (${e.code})';
  }
}

Future<void> _deleteAuthUserIfCreated(
  FirebaseAuthService auth,
  UserCredential? credential,
) async {
  if (credential?.user == null) return;
  try {
    await auth.deleteCurrentUser();
  } catch (_) {
    // Best-effort cleanup. The UI still receives the original error.
  }
}

Future<void> _rollbackRegistration(
  UserRepository repo,
  FirebaseAuthService auth,
  UserCredential? credential,
) async {
  final uid = credential?.user?.uid;
  if (uid == null) return;
  try {
    await repo.deleteUser(uid);
  } catch (_) {
    // The profile may not have been written yet.
  }
  await _deleteAuthUserIfCreated(auth, credential);
}

String _fallbackPhoneForUid(String uid) {
  final hash = uid.codeUnits.fold<int>(
    0,
    (value, codeUnit) => (value * 31 + codeUnit) & 0x7fffffff,
  );
  final suffix = (hash % 10000000).toString().padLeft(7, '0');
  return '090$suffix';
}
