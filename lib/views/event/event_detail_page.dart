import 'package:flutter/material.dart';

import '../../models/community_models.dart';
import 'event_list_page.dart';

class EventDetailPage extends StatelessWidget {
  final SportEvent event;
  final VoidCallback onBack;
  final VoidCallback onJoin;

  const EventDetailPage({
    super.key,
    required this.event,
    required this.onBack,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    final canJoin =
        event.active && !event.isFull && event.startAt.isAfter(DateTime.now());
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        title: const Text('Chi tiết sự kiện'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (event.imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                event.imageUrl,
                height: 210,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          const SizedBox(height: 18),
          Text(
            event.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          Chip(label: Text(event.sport)),
          const SizedBox(height: 14),
          _DetailRow(
            icon: Icons.schedule,
            label: 'Thời gian',
            value: formatCommunityDate(event.startAt),
          ),
          _DetailRow(
            icon: Icons.location_on_outlined,
            label: 'Địa điểm',
            value: event.location,
          ),
          _DetailRow(
            icon: Icons.groups_outlined,
            label: 'Số người',
            value: '${event.registeredCount}/${event.capacity}',
          ),
          _DetailRow(
            icon: Icons.person_outline,
            label: 'Người tạo',
            value: eventCreatorName(event),
          ),
          const SizedBox(height: 18),
          const Text(
            'Giới thiệu',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            event.description.isEmpty
                ? 'Thông tin sự kiện đang được cập nhật.'
                : event.description,
            style: const TextStyle(height: 1.55, color: Color(0xFF475569)),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton(
          onPressed: canJoin ? onJoin : null,
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 54),
          ),
          child: Text(event.isFull ? 'Đã đủ người' : 'Đăng ký sự kiện'),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: CircleAvatar(child: Icon(icon, size: 20)),
    title: Text(label),
    subtitle: Text(value),
  );
}
