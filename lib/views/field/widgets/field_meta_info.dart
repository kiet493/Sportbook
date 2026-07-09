import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class FieldMetaInfo extends StatelessWidget {
  final String address;
  final String hours;
  final String distance;

  const FieldMetaInfo({
    super.key,
    required this.address,
    required this.hours,
    required this.distance,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MetaItem(
          icon: Icons.location_on_outlined,
          value: address,
          isMultiline: true,
        ),
        const SizedBox(height: 8),
        _MetaItem(
          icon: Icons.access_time,
          value: hours,
        ),
        const SizedBox(height: 8),
        _MetaItem(
          icon: Icons.navigation_outlined,
          value: "$distance từ vị trí của bạn",
        ),
      ],
    );
  }
}

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final bool isMultiline;

  const _MetaItem({
    required this.icon,
    required this.value,
    this.isMultiline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Icon(icon, color: AppColors.primary, size: 16),
        const SizedBox(width: 8),
        if (isMultiline)
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          )
        else
          Text(
            value,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
      ],
    );
  }
}
