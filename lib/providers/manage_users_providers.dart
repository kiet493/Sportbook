import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import '../repositories/user_repository.dart';
import '../services/Firebase/firestore_service.dart';
import '../viewmodels/manage_users_view_model.dart';

/// Single instance of the Firestore service for user management.
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

/// Single instance of [UserRepository]. All ViewModels read this so
/// swapping the data backend happens in one place.
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(firestoreService: ref.watch(firestoreServiceProvider));
});

final allUsersProvider = StreamProvider<List<UserModel>>((ref) {
  return ref.watch(userRepositoryProvider).watchAll();
});

class UserListFilter {
  final String search;
  final String? role;
  final String? status;

  const UserListFilter({this.search = '', this.role, this.status});

  UserListFilter copyWith({
    String? search,
    Object? role = _sentinel,
    Object? status = _sentinel,
  }) {
    return UserListFilter(
      search: search ?? this.search,
      role: role == _sentinel ? this.role : role as String?,
      status: status == _sentinel ? this.status : status as String?,
    );
  }

  static const Object _sentinel = Object();
}

class UserListFilterNotifier extends Notifier<UserListFilter> {
  @override
  UserListFilter build() => const UserListFilter();

  void setSearch(String value) => state = state.copyWith(search: value);
  void setRole(String? value) => state = state.copyWith(role: value);
  void setStatus(String? value) => state = state.copyWith(status: value);
  void clear() => state = const UserListFilter();
}

final userListFilterProvider =
    NotifierProvider<UserListFilterNotifier, UserListFilter>(
      UserListFilterNotifier.new,
    );

/// The AsyncNotifier driving the manage-users CRUD screen.
final manageUsersViewModelProvider =
    AsyncNotifierProvider<ManageUsersViewModel, List<ManageUsersItem>>(
      ManageUsersViewModel.new,
    );

/// View-friendly projection of a [UserModel] plus its UI flags.
/// Kept in the provider file so the view only depends on the
/// Riverpod surface, not on the underlying repository.
class ManageUsersItem {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String role;
  final String status;
  final String staffVenueName;

  const ManageUsersItem({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    required this.status,
    this.staffVenueName = '',
  });
}
