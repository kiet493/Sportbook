import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// AppBar leading button. Centralized so every page uses the same
/// icon + color combo without redefining the hex values.
class BackChevronButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const BackChevronButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.chevron_left, color: AppColors.textPrimary),
      onPressed: onPressed ?? () => Navigator.of(context).maybePop(),
    );
  }
}
