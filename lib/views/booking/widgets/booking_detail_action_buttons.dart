import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/booking_model.dart';

/// Bottom action stack for the booking detail page.
///
/// Shows a destructive "Hủy đặt sân" button only when the booking is
/// still upcoming; otherwise shows a generic "rebook" + "contact" pair.
class BookingDetailActionButtons extends StatelessWidget {
  final String status;
  final VoidCallback? onCancel;
  final VoidCallback? onRebook;
  final VoidCallback? onContact;

  const BookingDetailActionButtons({
    super.key,
    required this.status,
    this.onCancel,
    this.onRebook,
    this.onContact,
  });

  @override
  Widget build(BuildContext context) {
    final isUpcoming = status == BookingStatus.upcoming;

    return Column(
      children: [
        if (isUpcoming && onCancel != null) ...[
          ElevatedButton(
            onPressed: onCancel,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dangerSurface,
              foregroundColor: AppColors.danger,
              elevation: 0,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(
                  color: AppColors.dangerSoft,
                  width: 1.5,
                ),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.close, size: 16),
                SizedBox(width: 8),
                Text(
                  'Hủy đặt sân',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
        if (onRebook != null) ...[
          _SecondaryButton(
            icon: Icons.refresh,
            label: 'Đặt lại sân này',
            onPressed: onRebook,
          ),
          const SizedBox(height: 10),
        ],
        if (onContact != null)
          _SecondaryButton(
            icon: Icons.chat_bubble_outline,
            label: 'Liên hệ ban quản lý',
            onPressed: onContact,
          ),
      ],
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const _SecondaryButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        backgroundColor: AppColors.surface,
        minimumSize: const Size(double.infinity, 50),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
