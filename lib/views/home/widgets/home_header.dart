import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// Top app-bar area showing greeting, location, a notification bell
/// with a badge, and a circular user avatar.
class HomeHeader extends StatelessWidget {
  final String greeting;
  final String name;
  final String location;
  final String avatarUrl;
  final bool hasNotification;
  final VoidCallback? onNotificationsTap;

  const HomeHeader({
    super.key,
    required this.greeting,
    required this.name,
    required this.location,
    required this.avatarUrl,
    this.hasNotification = true,
    this.onNotificationsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.surfaceMuted.withValues(alpha: 0.92),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _GreetingColumn(greeting: greeting, name: name, location: location),
          Row(
            children: [
              _NotificationBell(
                hasNotification: hasNotification,
                onTap: onNotificationsTap,
              ),
              const SizedBox(width: 8),
              _UserAvatar(avatarUrl: avatarUrl),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Private sub-widgets ────────────────────────────────────────────────────

class _GreetingColumn extends StatelessWidget {
  final String greeting;
  final String name;
  final String location;

  const _GreetingColumn({
    required this.greeting,
    required this.name,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          name,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            const Icon(Icons.location_on, size: 12, color: AppColors.primary),
            const SizedBox(width: 2),
            Text(
              location,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _NotificationBell extends StatelessWidget {
  final bool hasNotification;
  final VoidCallback? onTap;

  const _NotificationBell({required this.hasNotification, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Stack(children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.notifications_none,
            color: AppColors.textPrimary,
            size: 20,
          ),
        ),
        if (hasNotification)
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ]),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  final String avatarUrl;

  const _UserAvatar({required this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    final hasImage = avatarUrl.trim().isNotEmpty;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 2),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6),
        ],
        color: hasImage ? null : AppColors.primarySoft,
        image: hasImage
            ? DecorationImage(image: NetworkImage(avatarUrl), fit: BoxFit.cover)
            : null,
      ),
      child: hasImage
          ? null
          : const Icon(Icons.person, color: AppColors.primary, size: 22),
    );
  }
}
