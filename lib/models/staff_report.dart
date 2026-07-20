import 'package:cloud_firestore/cloud_firestore.dart';

class StaffReport {
  final String id;
  final String staffId;
  final String staffName;
  final String venueId;
  final String venueName;
  final String title;
  final String content;
  final bool resolved;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  const StaffReport({
    required this.id,
    required this.staffId,
    required this.staffName,
    required this.venueId,
    required this.venueName,
    required this.title,
    required this.content,
    required this.resolved,
    required this.createdAt,
    this.resolvedAt,
  });

  Map<String, dynamic> toJson() => {
    '_id': id,
    'staffId': staffId,
    'staffName': staffName,
    'venueId': venueId,
    'venueName': venueName,
    'title': title,
    'content': content,
    'resolved': resolved,
  };

  factory StaffReport.fromJson(Map<String, dynamic> json, String id) =>
      StaffReport(
        id: id,
        staffId: (json['staffId'] ?? '').toString(),
        staffName: (json['staffName'] ?? '').toString(),
        venueId: (json['venueId'] ?? '').toString(),
        venueName: (json['venueName'] ?? '').toString(),
        title: (json['title'] ?? '').toString(),
        content: (json['content'] ?? '').toString(),
        resolved: json['resolved'] == true,
        createdAt: _date(json['createdAt']) ?? DateTime.now(),
        resolvedAt: _date(json['resolvedAt']),
      );
}

DateTime? _date(Object? value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}
