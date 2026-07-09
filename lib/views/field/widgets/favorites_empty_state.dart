import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class FavoritesEmptyState extends StatelessWidget {
  final VoidCallback onExplore;

  const FavoritesEmptyState({
    super.key,
    required this.onExplore,
  });

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
              child: const Icon(
                Icons.favorite_border,
                color: AppColors.textMuted,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Chưa có sân yêu thích",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Nhấn vào biểu tượng ❤️ trên các thẻ sân để lưu.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onExplore,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: const Size(140, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                "Khám phá sân",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
