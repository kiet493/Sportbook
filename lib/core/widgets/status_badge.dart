import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Pill-shaped status indicator used in AppBars and cards.
///
/// Maps a [BookingStatus] value to a label + (background, text) pair.
/// Centralizing this avoids drift between the booking detail page,
/// booking history, and any future list view.
class StatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;

  const StatusBadge({
    super.key,
    required this.status,
    this.fontSize = 10,
  });

  ({Color background, Color foreground, String label}) _resolve(String s) {
    switch (s) {
      case 'completed':
        return (
          background: AppColors.successSoft,
          foreground: AppColors.success,
          label: 'Hoàn thành',
        );
      case 'cancelled':
        return (
          background: AppColors.dangerSoft,
          foreground: AppColors.dangerDeep,
          label: 'Đã hủy',
        );
      case 'upcoming':
      default:
        return (
          background: AppColors.primarySoft,
          foreground: AppColors.primaryDeep,
          label: 'Sắp tới',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final resolved = _resolve(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: resolved.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        resolved.label,
        style: TextStyle(
          color: resolved.foreground,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
