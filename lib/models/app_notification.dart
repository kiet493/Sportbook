import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type;
  final bool read;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.read,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> data, String id) {
    final rawCreatedAt = data['createdAt'];
    return AppNotification(
      id: id,
      userId: data['userId']?.toString() ?? '',
      title: data['title']?.toString() ?? 'Thông báo',
      body: data['body']?.toString() ?? '',
      type: data['type']?.toString() ?? 'general',
      read: data['read'] == true,
      createdAt: rawCreatedAt is Timestamp
          ? rawCreatedAt.toDate()
          : rawCreatedAt is DateTime ? rawCreatedAt : DateTime.now(),
    );
  }
}
