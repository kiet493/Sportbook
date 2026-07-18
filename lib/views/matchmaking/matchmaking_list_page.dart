import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/community_models.dart';
import '../../providers/community_providers.dart';
import '../event/event_list_page.dart';

class MatchmakingListPage extends ConsumerWidget {
  final VoidCallback onBack;
  final VoidCallback onCreate;
  final ValueChanged<MatchmakingRoom> onOpenRoom;
  final VoidCallback onOpenEvents;

  const MatchmakingListPage({
    super.key,
    required this.onBack,
    required this.onCreate,
    required this.onOpenRoom,
    required this.onOpenEvents,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rooms = ref.watch(matchmakingRoomsProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        title: const Text('Phòng ghép thể thao'),
        actions: [
          TextButton(onPressed: onOpenEvents, child: const Text('Sự kiện')),
        ],
      ),
      body: rooms.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Không thể tải phòng: $error')),
        data: (items) => items.isEmpty
            ? const Center(
                child: Text('Chưa có phòng ghép. Hãy tạo phòng mới!'),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final room = items[index];
                  return Card(
                    child: ListTile(
                      onTap: () => onOpenRoom(room),
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFFDBEAFE),
                        child: Text('${room.memberCount}/${room.maxMembers}'),
                      ),
                      title: Text(
                        room.title,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      subtitle: Text(
                        '${room.venueName}\n${formatCommunityDate(room.playAt)} · ${room.skillLevel}',
                      ),
                      isThreeLine: true,
                      trailing: Icon(
                        room.isFull ? Icons.lock_outline : Icons.chevron_right,
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: onCreate,
        icon: const Icon(Icons.add),
        label: const Text('Tạo phòng'),
      ),
    );
  }
}
