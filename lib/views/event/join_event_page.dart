import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/community_models.dart';
import '../../providers/community_providers.dart';
import '../../providers/registration_providers.dart';
import 'event_list_page.dart';

class JoinEventPage extends ConsumerStatefulWidget {
  final SportEvent event;
  final VoidCallback onBack;
  final VoidCallback onSuccess;

  const JoinEventPage({
    super.key,
    required this.event,
    required this.onBack,
    required this.onSuccess,
  });

  @override
  ConsumerState<JoinEventPage> createState() => _JoinEventPageState();
}

class _JoinEventPageState extends ConsumerState<JoinEventPage> {
  String? _error;

  Future<void> _join() async {
    final error = await ref
        .read(communityActionProvider.notifier)
        .registerEvent(widget.event);
    if (!mounted) return;
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đăng ký sự kiện thành công.'),
        backgroundColor: Color(0xFF16A34A),
      ),
    );
    widget.onSuccess();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(sessionProvider)?.user;
    final loading = ref.watch(communityActionProvider).isLoading;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          onPressed: widget.onBack,
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        title: const Text('Xác nhận đăng ký'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.event.title,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(formatCommunityDate(widget.event.startAt)),
                  Text(widget.event.location),
                  const SizedBox(height: 8),
                  const Text(
                    'Lệ phí tham gia: Miễn phí',
                    style: TextStyle(
                      color: Color(0xFF16A34A),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person_outline)),
              title: Text(user?.fullName ?? 'Người dùng'),
              subtitle: Text('${user?.phone ?? ''}\n${user?.email ?? ''}'),
              isThreeLine: true,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Thông tin liên hệ trong hồ sơ sẽ được gửi cho ban tổ chức.',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Color(0xFFDC2626))),
          ],
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: loading ? null : _join,
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 54),
            ),
            icon: loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.how_to_reg_outlined),
            label: const Text('Xác nhận đăng ký'),
          ),
        ],
      ),
    );
  }
}
