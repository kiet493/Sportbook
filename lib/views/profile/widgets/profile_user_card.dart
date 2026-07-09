import 'package:flutter/material.dart';

class ProfileUserCard extends StatelessWidget {
  const ProfileUserCard({super.key});

  static const _avatarUrl =
      "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=80&h=80&fit=crop&auto=format";

  @override
  Widget build(BuildContext context) {
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
      child: const Row(
        children: [
          _ProfileAvatar(imageUrl: _avatarUrl),
          SizedBox(width: 16),
          Expanded(child: _ProfileUserInfo()),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String imageUrl;

  const _ProfileAvatar({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2563EB), width: 2),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _ProfileUserInfo extends StatelessWidget {
  const _ProfileUserInfo();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Nguy\u1ec5n Minh Tu\u1ea5n",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        Text(
          "minhtuanfootball@gmail.com",
          style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
        ),
        SizedBox(height: 6),
        _MembershipBadge(),
      ],
    );
  }
}

class _MembershipBadge extends StatelessWidget {
  const _MembershipBadge();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.star, size: 12, color: Colors.amber),
        SizedBox(width: 4),
        Text(
          "Th\u00e0nh vi\u00ean V\u00e0ng",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Color(0xFFD97706),
          ),
        ),
      ],
    );
  }
}
