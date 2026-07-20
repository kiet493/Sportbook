import 'package:cloud_firestore/cloud_firestore.dart';

class VenueReview {
  final String id;
  final String venueId;
  final String userId;
  final String userName;
  final int rating;
  final String comment;
  final DateTime createdAt;

  const VenueReview({required this.id, required this.venueId, required this.userId, required this.userName, required this.rating, required this.comment, required this.createdAt});

  factory VenueReview.fromJson(Map<String, dynamic> data, String id) {
    final raw = data['createdAt'];
    return VenueReview(
      id: id, venueId: data['venueId']?.toString() ?? '', userId: data['userId']?.toString() ?? '',
      userName: data['userName']?.toString() ?? 'Người dùng', rating: (data['rating'] as num?)?.round() ?? 0,
      comment: data['comment']?.toString() ?? '', createdAt: raw is Timestamp ? raw.toDate() : DateTime.now(),
    );
  }
}
