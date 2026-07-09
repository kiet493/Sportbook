import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/venue.dart';
import 'home_sport_chip.dart';

/// Section header + horizontal scrollable list of sport-category chips.
class HomeSportsSection extends StatelessWidget {
  final List<SportsCategory> categories;
  final String activeSport;
  final ValueChanged<String> onSportSelected;
  final VoidCallback onSeeMore;

  const HomeSportsSection({
    super.key,
    required this.categories,
    required this.activeSport,
    required this.onSportSelected,
    required this.onSeeMore,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Môn thể thao',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: onSeeMore,
                child: Row(
                  children: const [
                    Text(
                      'Xem thêm',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 14,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 96,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return HomeSportChip(
                category: cat,
                isSelected: activeSport == cat.name,
                onTap: () => onSportSelected(cat.name),
              );
            },
          ),
        ),
      ],
    );
  }
}
