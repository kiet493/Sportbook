import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import '../repositories/user_repository.dart';
import '../services/Firebase/firebase_auth_service.dart';
import 'firebase_providers.dart';
import 'manage_users_providers.dart';

final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService();
});

/// Holds the currently authenticated user.
///
/// `null` ⇒ not signed in. The [AppRouter] redirects to the login
/// screen whenever this resolves to `null`. A banned user is *still*
/// represented as a non-null value — the router refuses to render the
/// home shell and shows a "banned" placeholder instead.
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

/// Result of a registration attempt. Either success (with a [UserModel])
/// or a user-facing error message keyed by field.
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

/// Drives the registration form. Keeps a single in-flight submit
/// accessible to the view via [AsyncValue] without conflating it with
/// the global list state used by the admin module.
class RegistrationNotifier extends AsyncNotifier<void> {
  @override
  void build() {}

  Future<RegistrationResult> submit({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String role,
    required String gender,
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
        role: role,
        gender: gender,
      );
      final created = await repo.createUser(user);
      ref.read(sessionProvider.notifier).setUser(created);
      state = const AsyncData(null);
      return RegistrationResult.success(created);
    } on FirebaseAuthException catch (e) {
      state = const AsyncData(null);
      return _registrationErrorFromAuth(e);
    } on UserValidationException catch (e) {
      await _deleteAuthUserIfCreated(auth, credential);
      state = AsyncData(null);
      return RegistrationResult.fieldError(e.code, e.message);
    } on FirebaseException catch (e) {
      await _deleteAuthUserIfCreated(auth, credential);
      state = AsyncError(e, StackTrace.current);
      return RegistrationResult.error(
        e.message ?? 'Firebase gặp lỗi (${e.code})',
      );
    } catch (e) {
      await _deleteAuthUserIfCreated(auth, credential);
      state = AsyncError(e, StackTrace.current);
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

      final repo = ref.read(userRepositoryProvider);
      final profile = await _ensureProfileForSignedInUser(
        repo: repo,
        firebaseUser: firebaseUser,
        fallbackEmail: email,
      );

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
    } on FirebaseException catch (e) {
      state = AsyncError(e, StackTrace.current);
      return _firestoreMessage(e);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
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
}

final loginProvider = AsyncNotifierProvider<LoginNotifier, bool>(
  LoginNotifier.new,
);

Future<UserModel> _ensureProfileForSignedInUser({
  required UserRepository repo,
  required User firebaseUser,
  required String fallbackEmail,
}) async {
  try {
    final existing = await repo.fetch(firebaseUser.uid);
    if (existing != null) return existing;

    final generatedProfile = _profileFromFirebaseUser(
      firebaseUser: firebaseUser,
      fallbackEmail: fallbackEmail,
    );
    return repo.createUser(generatedProfile);
  } on FirebaseException catch (e) {
    if (e.code == 'permission-denied') {
      return _profileFromFirebaseUser(
        firebaseUser: firebaseUser,
        fallbackEmail: fallbackEmail,
      );
    }
    rethrow;
  }
}

UserModel _profileFromFirebaseUser({
  required User firebaseUser,
  required String fallbackEmail,
}) {
  final email = firebaseUser.email ?? fallbackEmail.trim().toLowerCase();
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

String _fallbackPhoneForUid(String uid) {
  final hash = uid.codeUnits.fold<int>(
    0,
    (value, codeUnit) => (value * 31 + codeUnit) & 0x7fffffff,
  );
  return hash.toString().padLeft(10, '0').substring(0, 10);
}
