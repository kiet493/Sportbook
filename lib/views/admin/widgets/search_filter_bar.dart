import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/user_model.dart';
import '../../../providers/manage_users_providers.dart';

/// Search field plus horizontal role/status chip row.
///
/// Owns no state — the parent page passes the search
/// [TextEditingController] so the field can be pre-filled from the
/// saved filter and disposed together with the page.
class SearchFilterBar extends ConsumerWidget {
  final TextEditingController controller;

  const SearchFilterBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Column(
        children: [
          _SearchField(controller: controller),
          const SizedBox(height: 12),
          const _FilterRow(),
        ],
      ),
    );
  }
}

class _SearchField extends ConsumerWidget {
  final TextEditingController controller;
  const _SearchField({required this.controller});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextField(
      controller: controller,
      onChanged: (v) =>
          ref.read(userListFilterProvider.notifier).setSearch(v),
      decoration: InputDecoration(
        hintText: 'Tìm theo tên, email, số điện thoại…',
        prefixIcon: const Icon(Icons.search, size: 20),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }
}

class _FilterRow extends ConsumerWidget {
  const _FilterRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(userListFilterProvider);
    final notifier = ref.read(userListFilterProvider.notifier);

    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _FilterChip(
            label: 'Tất cả vai trò',
            selected: filter.role == null,
            onTap: () => notifier.setRole(null),
          ),
          for (final role in UserRole.all)
            _FilterChip(
              label: UserRole.label(role),
              selected: filter.role == role,
              onTap: () => notifier.setRole(role),
            ),
          const _FilterDivider(),
          _FilterChip(
            label: 'Mọi trạng thái',
            selected: filter.status == null,
            onTap: () => notifier.setStatus(null),
          ),
          for (final status in UserStatus.all)
            _FilterChip(
              label: UserStatus.label(status),
              selected: filter.status == status,
              onTap: () => notifier.setStatus(status),
            ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterDivider extends StatelessWidget {
  const _FilterDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: VerticalDivider(width: 12),
    );
  }
}