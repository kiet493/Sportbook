import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/section_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../models/user_model.dart';
import '../../../providers/manage_users_providers.dart';
import '../../../repositories/user_repository.dart';
import '../admin_utils.dart';
import '../user_detail_page.dart';

/// Single row inside the manage-users list. Hosts its own swipe-to-
/// delete confirmation since no other caller needs to reuse it.
class UserListItem extends ConsumerWidget {
  final ManageUsersItem item;
  const UserListItem({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context, ref),
      background: const _DeleteSwipeBackground(),
      child: SectionCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _openDetail(context, ref),
          child: _UserCardBody(item: item),
        ),
      ),
    );
  }

  Future<void> _openDetail(BuildContext context, WidgetRef ref) async {
    final user = await ref
        .read(manageUsersViewModelProvider.notifier)
        .fetchById(item.id);
    if (!context.mounted || user == null) return;
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => UserDetailPage(user: user)));
  }

  Future<bool> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await _DeleteUserDialog.ask(context, name: item.fullName);
    if (confirmed != true) return false;
    if (!context.mounted) return false;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(manageUsersViewModelProvider.notifier).delete(item.id);
      messenger.showSnackBar(const SnackBar(content: Text('Đã xóa tài khoản')));
    } on UserValidationException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Không thể xóa: $e')));
    }
    return false;
  }
}

// ─── Internal sub-widgets ─────────────────────────────────────────────────

class _UserCardBody extends StatelessWidget {
  final ManageUsersItem item;
  const _UserCardBody({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _UserAvatar(initials: adminInitials(item.fullName)),
        const SizedBox(width: 12),
        Expanded(child: _UserInfoColumn(item: item)),
        const Icon(Icons.chevron_right, color: AppColors.textMuted),
      ],
    );
  }
}

class _UserAvatar extends StatelessWidget {
  final String initials;
  const _UserAvatar({required this.initials});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: AppColors.primarySoft,
      child: Text(
        initials,
        style: const TextStyle(
          color: AppColors.primaryDeep,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _UserInfoColumn extends StatelessWidget {
  final ManageUsersItem item;
  const _UserInfoColumn({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.fullName,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          item.email,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            StatusBadge(status: item.status, fontSize: 10),
            _RolePill(role: item.role),
          ],
        ),
        if (item.role == UserRole.staff && item.staffVenueName.isNotEmpty) ...[
          const SizedBox(height: 5),
          Text(
            'Cụm sân: ${item.staffVenueName}',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

class _RolePill extends StatelessWidget {
  final String role;
  const _RolePill({required this.role});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        UserRole.label(role),
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DeleteSwipeBackground extends StatelessWidget {
  const _DeleteSwipeBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.danger,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Icon(Icons.delete, color: Colors.white),
    );
  }
}

/// Confirmation dialog before deleting a user from the list.
class _DeleteUserDialog {
  static Future<bool?> ask(BuildContext context, {required String name}) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa tài khoản?'),
        content: Text('"$name" sẽ bị xóa vĩnh viễn.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
