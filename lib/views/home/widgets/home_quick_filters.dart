import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// Horizontal scrollable row of [ChoiceChip] filter pills.
class HomeQuickFilters extends StatelessWidget {
  final List<String> filters;
  final String activeFilter;
  final ValueChanged<String> onFilterSelected;

  const HomeQuickFilters({
    super.key,
    required this.filters,
    required this.activeFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = activeFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                filter,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) onFilterSelected(filter);
              },
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surface,
              elevation: isSelected ? 4 : 0,
              pressElevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color:
                      isSelected ? AppColors.primary : AppColors.border,
                  width: 1.5,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
