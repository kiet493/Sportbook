import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Two-column "label : value" row with a bottom hairline.
///
/// Used inside [SectionCard] to render the booking info list. The last
/// row in a card should pass [isLast] = true to suppress the divider.
class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBoldValue;
  final bool isLast;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.isBoldValue = false,
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
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBoldValue ? FontWeight.bold : FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
