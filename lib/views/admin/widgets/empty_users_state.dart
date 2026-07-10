import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// Empty state shown when the manage-users list returns no rows.
class EmptyUsersState extends StatelessWidget {
  const EmptyUsersState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            _EmptyIcon(),
            SizedBox(height: 16),
            Text(
              'Không có tài khoản nào',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Thử thay đổi bộ lọc hoặc tạo tài khoản mới.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyIcon extends StatelessWidget {
  const _EmptyIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Icon(
        Icons.people_outline,
        color: AppColors.primary,
        size: 36,
      ),
    );
  }
}

/// Error placeholder for the manage-users list view.
class UsersErrorState extends StatelessWidget {
  final String message;
  const UsersErrorState({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                color: AppColors.danger, size: 36),
            const SizedBox(height: 12),
            const Text(
              'Không thể tải danh sách',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}