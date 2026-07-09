import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// Tappable fake search bar that navigates the user to the Search page.
class HomeSearchBar extends StatelessWidget {
  final VoidCallback onTap;

  const HomeSearchBar({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Hôm nay muốn chơi môn gì?',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.tune, color: Colors.white, size: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
