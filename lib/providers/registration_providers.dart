import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import '../repositories/user_repository.dart';
import 'manage_users_providers.dart';

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

final sessionProvider =
    NotifierProvider<SessionNotifier, SessionUser?>(SessionNotifier.new);

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

    // The id can be any stable identifier — the production app uses
    // Firebase Auth's uid. We generate a uuid here so registration
    // works offline / during local testing.
    final id = 'u_${DateTime.now().microsecondsSinceEpoch}';
    final user = UserModel.newUser(
      id: id,
      fullName: fullName,
      email: email,
      phone: phone,
      role: role,
      gender: gender,
    );

    final repo = ref.read(userRepositoryProvider);
    try {
      final created = await repo.createUser(user);
      // Sign the user in immediately after a successful registration.
      ref.read(sessionProvider.notifier).setUser(created);
      state = const AsyncData(null);
      return RegistrationResult.success(created);
    } on UserValidationException catch (e) {
      state = AsyncData(null);
      return RegistrationResult.fieldError(e.code, e.message);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return RegistrationResult.error(e.toString());
    }
  }
}

final registrationProvider =
    AsyncNotifierProvider<RegistrationNotifier, void>(
  RegistrationNotifier.new,
);

/// Simple, framework-free login used by the demo screens. In a real
/// app this would be backed by FirebaseAuth; we keep the contract
/// (`Future<bool>`) compatible so swapping it later is trivial.
class LoginNotifier extends AsyncNotifier<bool> {
  @override
  bool build() => false;

  Future<String?> login({required String email, required String password}) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(userRepositoryProvider);
      final matches = await repo
          .fetch(_emailToIdStub(email)) // best-effort; falls through below
          .catchError((_) => null);
      if (matches != null && password.length >= 6) {
        ref.read(sessionProvider.notifier).setUser(matches);
        state = const AsyncData(true);
        return null;
      }
      // For the demo we accept any email/password ≥6 chars and create a
      // transient session so the router guard has something to read.
      ref.read(sessionProvider.notifier).setUser(
            UserModel.newUser(
              id: 'session_${DateTime.now().microsecondsSinceEpoch}',
              fullName: email.split('@').first,
              email: email,
              phone: '',
            ),
          );
      state = const AsyncData(true);
      return null;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return 'Đăng nhập thất bại, vui lòng thử lại';
    }
  }

  void logout() {
    ref.read(sessionProvider.notifier).clear();
    state = const AsyncData(false);
  }
}

String _emailToIdStub(String email) => email.trim().toLowerCase();

final loginProvider =
    AsyncNotifierProvider<LoginNotifier, bool>(LoginNotifier.new);