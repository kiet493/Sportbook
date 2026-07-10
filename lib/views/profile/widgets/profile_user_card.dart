import 'package:flutter/material.dart';

import '../../../models/user_model.dart';

class ProfileUserCard extends StatelessWidget {
  final UserModel? user;

  const ProfileUserCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final name = _displayName;
    final email = _displayEmail;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _ProfileAvatar(imageUrl: user?.avatarUrl.trim() ?? '', name: name),
          const SizedBox(width: 16),
          Expanded(
            child: _ProfileUserInfo(
              name: name,
              email: email,
              role: user?.role ?? UserRole.user,
              isBanned: user?.isBanned ?? false,
            ),
          ),
        ],
      ),
    );
  }

  String get _displayName {
    final fullName = user?.fullName.trim() ?? '';
    if (fullName.isNotEmpty) return fullName;

    final email = user?.email.trim() ?? '';
    if (email.isNotEmpty) return email.split('@').first;

    return 'Người dùng SportBook';
  }

  String get _displayEmail {
    final email = user?.email.trim() ?? '';
    return email.isNotEmpty ? email : 'Chưa có email';
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String imageUrl;
  final String name;

  const _ProfileAvatar({required this.imageUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2563EB), width: 2),
      ),
      child: imageUrl.isEmpty
          ? _FallbackAvatar(name: name)
          : Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _FallbackAvatar(name: name),
            ),
    );
  }
}

class _ProfileUserInfo extends StatelessWidget {
  final String name;
  final String email;
  final String role;
  final bool isBanned;

  const _ProfileUserInfo({
    required this.name,
    required this.email,
    required this.role,
    required this.isBanned,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        Text(
          email,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 6),
        _MembershipBadge(
          label: isBanned
              ? UserStatus.label(UserStatus.banned)
              : UserRole.label(role),
          isBanned: isBanned,
        ),
      ],
    );
  }
}

class _MembershipBadge extends StatelessWidget {
  final String label;
  final bool isBanned;

  const _MembershipBadge({required this.label, required this.isBanned});

  @override
  Widget build(BuildContext context) {
    final color = isBanned ? const Color(0xFFDC2626) : const Color(0xFFD97706);

    return Row(
      children: [
        Icon(isBanned ? Icons.lock : Icons.star, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _FallbackAvatar extends StatelessWidget {
  final String name;

  const _FallbackAvatar({required this.name});

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? 'S' : name.trim()[0].toUpperCase();

    return ColoredBox(
      color: const Color(0xFFEFF6FF),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: Color(0xFF2563EB),
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
