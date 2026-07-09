import 'package:flutter/material.dart';

/// App-wide color palette.
///
/// Names mirror the Tailwind-like slate/blue scale used in the Figma
/// screens. Keep this file the single source of truth for raw color
/// values; widgets and themes should reference these constants.
class AppColors {
  AppColors._();

  // Surfaces
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF1F5F9);

  // Borders / dividers
  static const Color border = Color(0xFFE2E8F0);

  // Text
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  // Brand
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryDeep = Color(0xFF1D4ED8);
  static const Color primarySoft = Color(0xFFDBEAFE);

  // Semantic
  static const Color success = Color(0xFF15803D);
  static const Color successSoft = Color(0xFFDCFCE7);
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerDeep = Color(0xFFB91C1C);
  static const Color dangerSoft = Color(0xFFFEE2E2);
  static const Color dangerSurface = Color(0xFFFEF2F2);
}
