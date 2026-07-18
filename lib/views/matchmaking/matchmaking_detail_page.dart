import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/community_models.dart';
import '../../providers/community_providers.dart';
import '../event/event_list_page.dart';

class MatchmakingDetailPage extends ConsumerStatefulWidget {
  final MatchmakingRoom room;
  final VoidCallback onBack;

  const MatchmakingDetailPage({
    super.key,
    required this.room,
    required this.onBack,
  });

  @override
  ConsumerState<MatchmakingDetailPage> createState() =>
      _MatchmakingDetailPageState();
}

class _MatchmakingDetailPageState extends ConsumerState<MatchmakingDetailPage> {
  String? _error;

  Future<void> _join() async {
    final error = await ref
        .read(communityActionProvider.notifier)
        .joinRoom(widget.room);
    if (!mounted) return;
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã tham gia phòng ghép.'),
        backgroundColor: Color(0xFF16A34A),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final members = ref.watch(matchmakingMembersProvider(widget.room.id));
    final loading = ref.watch(communityActionProvider).isLoading;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          onPressed: widget.onBack,
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        title: const Text('Chi tiết phòng ghép'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            widget.room.title,
            style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          Text('${widget.room.sport} · ${widget.room.skillLevel}'),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: const Text('Địa điểm'),
                  subtitle: Text(widget.room.venueName),
                ),
                ListTile(
                  leading: const Icon(Icons.schedule),
                  title: const Text('Thời gian'),
                  subtitle: Text(formatCommunityDate(widget.room.playAt)),
                ),
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Người tạo'),
                  subtitle: Text(widget.room.creatorName),
                ),
              ],
            ),
          ),
          if (widget.room.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(widget.room.description),
          ],
          const SizedBox(height: 22),
          const Text(
            'Thành viên',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          members.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Text('Không thể tải thành viên: $error'),
            data: (items) => Column(
              children: [
                for (final member in items)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      child: Text(
                        member.userName.isEmpty
                            ? '?'
                            : member.userName.substring(0, 1).toUpperCase(),
                      ),
                    ),
                    title: Text(member.userName),
                    subtitle: Text(member.phone),
                  ),
              ],
            ),
          ),
          if (_error != null)
            Text(_error!, style: const TextStyle(color: Color(0xFFDC2626))),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton.icon(
          onPressed: loading || !widget.room.isOpen || widget.room.isFull
              ? null
              : _join,
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 54),
          ),
          icon: const Icon(Icons.group_add_outlined),
          label: Text(
            widget.room.isFull ? 'Phòng đã đủ người' : 'Tham gia phòng',
          ),
        ),
      ),
    );
  }
}
