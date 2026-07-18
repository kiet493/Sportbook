import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/community_models.dart';
import '../../providers/community_providers.dart';

class EventListPage extends ConsumerWidget {
  final VoidCallback onBack;
  final ValueChanged<SportEvent> onOpenEvent;
  final VoidCallback onOpenMatchmaking;

  const EventListPage({
    super.key,
    required this.onBack,
    required this.onOpenEvent,
    required this.onOpenMatchmaking,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(eventsProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        title: const Text('Sự kiện thể thao'),
        actions: [
          TextButton.icon(
            onPressed: onOpenMatchmaking,
            icon: const Icon(Icons.groups_outlined),
            label: const Text('Ghép đội'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(eventsProvider);
          await ref.read(eventsProvider.future);
        },
        child: events.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _MessageList(
            icon: Icons.cloud_off,
            text: 'Không thể tải sự kiện.\n$error',
          ),
          data: (items) => items.isEmpty
              ? const _MessageList(
                  icon: Icons.event_busy_outlined,
                  text: 'Chưa có sự kiện sắp diễn ra.',
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => _EventCard(
                    event: items[index],
                    onTap: () => onOpenEvent(items[index]),
                  ),
                ),
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final SportEvent event;
  final VoidCallback onTap;

  const _EventCard({required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.imageUrl.isNotEmpty)
              Image.network(
                event.imageUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Chip(label: Text(event.sport)),
                      const Spacer(),
                      Text(
                        '${event.registeredCount}/${event.capacity} người',
                        style: TextStyle(
                          color: event.isFull
                              ? const Color(0xFFDC2626)
                              : const Color(0xFF16A34A),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _Info(
                    icon: Icons.schedule,
                    text: formatCommunityDate(event.startAt),
                  ),
                  const SizedBox(height: 6),
                  _Info(icon: Icons.location_on_outlined, text: event.location),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Info extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Info({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 17, color: const Color(0xFF64748B)),
      const SizedBox(width: 7),
      Expanded(
        child: Text(text, style: const TextStyle(color: Color(0xFF64748B))),
      ),
    ],
  );
}

class _MessageList extends StatelessWidget {
  final IconData icon;
  final String text;
  const _MessageList({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    children: [
      const SizedBox(height: 160),
      Icon(icon, size: 64, color: const Color(0xFF94A3B8)),
      const SizedBox(height: 16),
      Text(text, textAlign: TextAlign.center),
    ],
  );
}

String formatCommunityDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$hour:$minute - $day/$month/${date.year}';
}
