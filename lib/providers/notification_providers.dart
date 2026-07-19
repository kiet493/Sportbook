import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_notification.dart';
import '../services/Firebase/notification_firestore_service.dart';
import 'firebase_providers.dart';

final notificationFirestoreServiceProvider = Provider<NotificationFirestoreService>(
  (ref) => NotificationFirestoreService(),
);

final userNotificationsProvider = StreamProvider<List<AppNotification>>((ref) {
  final user = ref.watch(firebaseAuthStateProvider).valueOrNull;
  if (user == null) return Stream.value(const []);
  return ref.watch(notificationFirestoreServiceProvider).watchForUser(user.uid);
});
