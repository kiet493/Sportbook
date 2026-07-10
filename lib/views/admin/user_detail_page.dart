import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/back_chevron_button.dart';
import '../../core/widgets/section_card.dart';
import '../../models/user_model.dart';
import '../../providers/manage_users_providers.dart';
import 'admin_utils.dart';
import 'widgets/admin_section_widgets.dart';

/// Read-only view of a single user. Mutations are exposed through
/// action buttons that delegate to the form dialog / ban toggle.
class UserDetailPage extends ConsumerWidget {
  final UserModel user;
  final VoidCallback? onEdit;

  const UserDetailPage({super.key, required this.user, this.onEdit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          AdminUserHeaderCard(
            user: user,
            initials: adminInitials(user.fullName),
          ),
          const SizedBox(height: 16),
          const _SectionTitleCard(text: 'Thông tin cơ bản'),
          const SizedBox(height: 12),
          _BasicInfoCard(user: user),
          const SizedBox(height: 16),
          _ExtraInfoCard(user: user),
          const SizedBox(height: 24),
          _DetailActionButtons(user: user, onEdit: onEdit),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) => AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: const BackChevronButton(),
        title: const Text(
          'Chi tiết tài khoản',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      );
}

// ─── Internal section widgets ─────────────────────────────────────────────

class _SectionTitleCard extends StatelessWidget {
  final String text;
  const _SectionTitleCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return const SectionCard(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: AdminSectionTitle(text: 'Thông tin cơ bản'),
    );
  }
}

class _BasicInfoCard extends StatelessWidget {
  final UserModel user;
  const _BasicInfoCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          AdminInfoRow(label: 'Họ tên', value: user.fullName),
          AdminInfoRow(label: 'Email', value: user.email),
          AdminInfoRow(label: 'Số điện thoại', value: user.phone),
          AdminInfoRow(
            label: 'Giới tính',
            value: UserGender.label(user.gender),
          ),
          AdminInfoRow(
            label: 'Vai trò',
            value: UserRole.label(user.role),
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _ExtraInfoCard extends StatelessWidget {
  final UserModel user;
  const _ExtraInfoCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          AdminInfoRow(
            label: 'Trạng thái',
            value: UserStatus.label(user.status),
          ),
          AdminInfoRow(
            label: 'Ngày sinh',
            value: user.dateOfBirth != null
                ? adminFormatDate(user.dateOfBirth!)
                : '—',
          ),
          AdminInfoRow(
            label: 'Địa chỉ',
            value: user.address.isEmpty ? '—' : user.address,
          ),
          AdminInfoRow(
            label: 'Ngày tạo',
            value: adminFormatDate(user.createdAt),
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _DetailActionButtons extends ConsumerWidget {
  final UserModel user;
  final VoidCallback? onEdit;

  const _DetailActionButtons({required this.user, this.onEdit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final banned = user.isBanned;
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _confirmBan(context, ref),
            icon: Icon(
              banned ? Icons.lock_open : Icons.block,
              size: 18,
            ),
            label: Text(banned ? 'Mở khóa' : 'Khóa tài khoản'),
            style: OutlinedButton.styleFrom(
              foregroundColor:
                  banned ? AppColors.primaryDeep : AppColors.dangerDeep,
              side: BorderSide(
                color: banned ? AppColors.primary : AppColors.danger,
              ),
              minimumSize: const Size(0, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit, size: 18),
            label: const Text('Chỉnh sửa'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size(0, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmBan(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await _BanUserDialog.ask(context, banned: user.isBanned);
    if (confirmed != true) return;

    try {
      await ref
          .read(manageUsersViewModelProvider.notifier)
          .toggleBan(user);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            user.isBanned ? 'Đã mở khóa tài khoản' : 'Đã khóa tài khoản',
          ),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Không thể cập nhật: $e')),
      );
    }
  }
}

/// Confirmation dialog for ban / unban on the detail page.
class _BanUserDialog {
  static Future<bool?> ask(BuildContext context, {required bool banned}) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(banned ? 'Mở khóa tài khoản?' : 'Khóa tài khoản?'),
        content: Text(
          banned
              ? 'Người dùng sẽ có thể đăng nhập lại.'
              : 'Người dùng sẽ bị cấm truy cập cho tới khi mở khóa.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(banned ? 'Mở khóa' : 'Khóa'),
          ),
        ],
      ),
    );
  }
}