import 'package:flutter/material.dart';

import '../../../models/venue.dart';

/// A single animated sport-category chip used in the horizontal
/// categories row on the Home page.
class HomeSportChip extends StatelessWidget {
  final SportsCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const HomeSportChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected ? category.color : category.bg,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: category.color.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                category.icon,
                color: isSelected ? Colors.white : category.color,
                size: 22,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              category.name,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isSelected ? category.color : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
