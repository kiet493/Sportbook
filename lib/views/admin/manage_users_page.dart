import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/back_chevron_button.dart';
import '../../providers/manage_users_providers.dart';
import 'user_form_dialog.dart';
import 'widgets/search_filter_bar.dart';
import 'widgets/user_list_view.dart';

/// Top-level admin screen — composes [SearchFilterBar] + [UserListView].
///
/// State (search controller, refresh callback) lives here so the
/// widgets below can stay purely presentational.
class ManageUsersPage extends ConsumerStatefulWidget {
  const ManageUsersPage({super.key});

  @override
  ConsumerState<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends ConsumerState<ManageUsersPage> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController =
        TextEditingController(text: ref.read(userListFilterProvider).search);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    ref.invalidate(manageUsersViewModelProvider);
    // Give the stream a tick to emit before the indicator dismisses.
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          SearchFilterBar(controller: _searchController),
          const SizedBox(height: 4),
          Expanded(child: UserListView(onRefresh: _refresh)),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) => AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: const BackChevronButton(),
        title: const Text(
          'Quản lý tài khoản',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Tạo tài khoản',
            onPressed: () => UserFormDialog.show(context),
            icon: const Icon(Icons.person_add_alt_1, color: AppColors.primary),
          ),
        ],
      );
}