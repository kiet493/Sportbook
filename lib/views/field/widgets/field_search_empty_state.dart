import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class FieldSearchEmptyState extends StatelessWidget {
  final List<String> recentSearches;
  final List<String> popularSearches;
  final ValueChanged<String> onRecentTap;
  final ValueChanged<String> onPopularTap;
  final VoidCallback onClearRecent;

  const FieldSearchEmptyState({
    super.key,
    required this.recentSearches,
    required this.popularSearches,
    required this.onRecentTap,
    required this.onPopularTap,
    required this.onClearRecent,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (recentSearches.isNotEmpty) ...[
            _RecentSearchesSection(
              recentSearches: recentSearches,
              onRecentTap: onRecentTap,
              onClearRecent: onClearRecent,
            ),
            const SizedBox(height: 16),
          ],
          _PopularSearchesSection(
            popularSearches: popularSearches,
            onPopularTap: onPopularTap,
          ),
        ],
      ),
    );
  }
}

class _RecentSearchesSection extends StatelessWidget {
  final List<String> recentSearches;
  final ValueChanged<String> onRecentTap;
  final VoidCallback onClearRecent;

  const _RecentSearchesSection({
    required this.recentSearches,
    required this.onRecentTap,
    required this.onClearRecent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Tìm kiếm gần đây",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: onClearRecent,
              child: const Text(
                "Xóa tất cả",
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...recentSearches.map((s) => _RecentSearchItem(
              search: s,
              onTap: () => onRecentTap(s),
            )),
      ],
    );
  }
}

class _RecentSearchItem extends StatelessWidget {
  final String search;
  final VoidCallback onTap;

  const _RecentSearchItem({required this.search, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        tileColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        leading: const Icon(Icons.schedule, color: AppColors.textMuted, size: 16),
        title: Text(
          search,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward, color: AppColors.textMuted, size: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        dense: true,
      ),
    );
  }
}

class _PopularSearchesSection extends StatelessWidget {
  final List<String> popularSearches;
  final ValueChanged<String> onPopularTap;

  const _PopularSearchesSection({
    required this.popularSearches,
    required this.onPopularTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "Phổ biến",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: popularSearches.map((s) {
            return ActionChip(
              onPressed: () => onPopularTap(s),
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.border),
              ),
              avatar: const Icon(
                Icons.trending_up,
                color: AppColors.primary,
                size: 14,
              ),
              label: Text(
                s,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class FieldSearchEmptyResults extends StatelessWidget {
  const FieldSearchEmptyResults({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.search_off, color: AppColors.textMuted, size: 28),
            ),
            const SizedBox(height: 16),
            const Text(
              "Không tìm thấy kết quả",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Thử từ khóa khác hoặc điều chỉnh bộ lọc.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
