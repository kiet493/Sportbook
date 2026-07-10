import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/section_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../models/user_model.dart';

/// Two-column "label : value" row with a bottom hairline.
class AdminInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const AdminInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: AppColors.surfaceMuted, width: 1.0),
              ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Section title used between info groups on the detail page.
class AdminSectionTitle extends StatelessWidget {
  final String text;
  const AdminSectionTitle({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

/// Pill rendering a translated role (admin/staff/user).
class AdminRolePill extends StatelessWidget {
  final String role;
  const AdminRolePill({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        UserRole.label(role),
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Header card on the user detail page — avatar, name, email,
/// status badge and role chip.
class AdminUserHeaderCard extends StatelessWidget {
  final UserModel user;
  final String initials;

  const AdminUserHeaderCard({
    super.key,
    required this.user,
    required this.initials,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.primarySoft,
            child: Text(
              initials,
              style: const TextStyle(
                color: AppColors.primaryDeep,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            user.fullName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StatusBadge(status: user.status, fontSize: 11),
              const SizedBox(width: 6),
              AdminRolePill(role: user.role),
            ],
          ),
        ],
      ),
    );
  }
}