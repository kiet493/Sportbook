import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/back_chevron_button.dart';
import '../../providers/firebase_providers.dart';
import '../../providers/notification_providers.dart';

class NotificationsPage extends ConsumerWidget {
  final VoidCallback onBack;
  const NotificationsPage({super.key, required this.onBack});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(userNotificationsProvider);
    final userId = ref.watch(firebaseAuthStateProvider).valueOrNull?.uid;
    return Scaffold(
      appBar: AppBar(
        leading: BackChevronButton(onPressed: onBack),
        title: const Text('Thông báo'),
        actions: [
          if (userId != null) TextButton(
            onPressed: () => ref.read(notificationFirestoreServiceProvider).markAllRead(userId),
            child: const Text('Đã đọc hết'),
          ),
        ],
      ),
      body: notifications.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(child: Text('Không tải được thông báo.')),
        data: (items) => items.isEmpty
            ? const Center(child: Text('Bạn chưa có thông báo nào.'))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (_, index) {
                  final item = items[index];
                  return ListTile(
                    tileColor: item.read ? Colors.white : const Color(0xFFEFF6FF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    leading: Icon(item.type == 'booking' ? Icons.event_available : Icons.notifications, color: const Color(0xFF2563EB)),
                    title: Text(item.title, style: TextStyle(fontWeight: item.read ? FontWeight.w600 : FontWeight.w800)),
                    subtitle: Text(item.body),
                  );
                },
              ),
      ),
    );
  }
}
