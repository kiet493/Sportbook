import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/manage_users_providers.dart';
import 'empty_users_state.dart';
import 'user_list_item.dart';

/// Renders the [AsyncValue] from `manageUsersViewModelProvider` and
/// delegates to the appropriate state widget.
///
/// Stateless and presentational — the parent owns the
/// [RefreshIndicator] callback (typically an `invalidate` + delay).
class UserListView extends ConsumerWidget {
  final Future<void> Function() onRefresh;

  const UserListView({super.key, required this.onRefresh});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncUsers = ref.watch(manageUsersViewModelProvider);
    return asyncUsers.when(
      data: (users) => users.isEmpty
          ? const EmptyUsersState()
          : _UserListBody(users: users, onRefresh: onRefresh),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => UsersErrorState(message: '$e'),
    );
  }
}

class _UserListBody extends StatelessWidget {
  final List<ManageUsersItem> users;
  final Future<void> Function() onRefresh;

  const _UserListBody({required this.users, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemBuilder: (_, i) => UserListItem(item: users[i]),
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemCount: users.length,
      ),
    );
  }
}
