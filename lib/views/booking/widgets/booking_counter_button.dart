import 'package:flutter/material.dart';

/// Small circular +/- stepper button used by counter rows.
class BookingCounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool isPrimary;

  const BookingCounterButton({
    super.key,
    required this.icon,
    this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: disabled
              ? const Color(0xFFF1F5F9)
              : isPrimary
                  ? const Color(0xFF2563EB)
                  : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Icon(
          icon,
          size: 16,
          color: disabled
              ? const Color(0xFFCBD5E1)
              : isPrimary
                  ? Colors.white
                  : const Color(0xFF0F172A),
        ),
      ),
    );
  }
}
