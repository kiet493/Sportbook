import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Rounded white card with a 1px border — the standard container used
/// by venue, timeline, info, and QR sections on the booking detail
/// page. Accepts an optional [padding] override for sections that need
/// less internal padding (e.g. the venue card uses edge-to-edge imagery).
class SectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  const SectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}
