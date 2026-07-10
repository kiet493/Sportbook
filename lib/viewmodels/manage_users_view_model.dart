import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import '../providers/manage_users_providers.dart';

/// Async state for the manage-users screen.
///
/// The state is a list of [ManageUsersItem]s — a flat projection of
/// [UserModel] — so widgets don't have to chase fields through three
/// levels of helpers. The list is filtered through [UserListFilter]
/// so search and role/status chips update without re-querying Firestore.
class ManageUsersViewModel extends AsyncNotifier<List<ManageUsersItem>> {
  StreamSubscription<List<UserModel>>? _sub;
  String _search = '';
  String? _role;
  String? _status;

  @override
  Future<List<ManageUsersItem>> build() async {
    // React to filter changes — keeps the stream alive while filters
    // mutate, and tears it down automatically when the provider is
    // disposed (ref.onDispose).
    final filter = ref.watch(userListFilterProvider);
    _search = filter.search.trim().toLowerCase();
    _role = filter.role;
    _status = filter.status;

    final repo = ref.read(userRepositoryProvider);
    final completer = Completer<List<ManageUsersItem>>();

    _sub?.cancel();
    _sub = repo.watchAll().listen(
      (users) {
        if (!completer.isCompleted) {
          completer.complete(_project(users));
        } else {
          state = AsyncData(_project(users));
        }
      },
      onError: (Object e, StackTrace st) {
        if (!completer.isCompleted) {
          completer.completeError(e, st);
        } else {
          state = AsyncError(e, st);
        }
      },
    );

    ref.onDispose(() => _sub?.cancel());

    return completer.future;
  }

  List<ManageUsersItem> _project(List<UserModel> users) {
    final filtered = users.where((u) {
      if (_role != null && u.role != _role) return false;
      if (_status != null && u.status != _status) return false;
      if (_search.isEmpty) return true;
      return u.fullName.toLowerCase().contains(_search) ||
          u.email.toLowerCase().contains(_search) ||
          u.phone.contains(_search);
    }).toList(growable: false);

    return filtered
        .map(
          (u) => ManageUsersItem(
            id: u.id,
            fullName: u.fullName,
            email: u.email,
            phone: u.phone,
            role: u.role,
            status: u.status,
          ),
        )
        .toList(growable: false);
  }

  // ─── Mutations ─────────────────────────────────────────────────────────

  /// Create flow: validate (handled inside the repository), persist,
  /// then re-emit so subscribers see the new row immediately.
  Future<UserModel> create(UserModel user) async {
    final repo = ref.read(userRepositoryProvider);
    final created = await repo.createUser(user);
    // The stream subscription will pick up the change and refresh
    // `state` automatically — but we expose this future so callers
    // can await confirmation and show a snackbar.
    return created;
  }

  Future<UserModel> updateUser(UserModel user) async {
    final repo = ref.read(userRepositoryProvider);
    return repo.updateUser(user);
  }

  Future<void> delete(String id) async {
    final repo = ref.read(userRepositoryProvider);
    await repo.deleteUser(id);
  }

  Future<void> toggleBan(UserModel user) async {
    final repo = ref.read(userRepositoryProvider);
    await repo.setBanned(user.id, banned: !user.isBanned);
  }

  Future<UserModel?> fetchById(String id) {
    final repo = ref.read(userRepositoryProvider);
    return repo.fetch(id);
  }
}