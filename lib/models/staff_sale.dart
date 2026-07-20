import 'package:cloud_firestore/cloud_firestore.dart';

class StaffSale {
  static const int waterUnitPrice = 30000;
  static const int racketUnitPrice = 100000;

  final String id;
  final String bookingId;
  final String venueId;
  final String dateKey;
  final String staffId;
  final String staffName;
  final int waterQuantity;
  final int racketQuantity;
  final DateTime updatedAt;

  const StaffSale({
    required this.id,
    required this.bookingId,
    required this.venueId,
    required this.dateKey,
    required this.staffId,
    required this.staffName,
    required this.waterQuantity,
    required this.racketQuantity,
    required this.updatedAt,
  });

  int get waterRevenue => waterQuantity * waterUnitPrice;
  int get racketRevenue => racketQuantity * racketUnitPrice;
  int get totalRevenue => waterRevenue + racketRevenue;

  Map<String, dynamic> toJson() => {
    '_id': id,
    'bookingId': bookingId,
    'venueId': venueId,
    'dateKey': dateKey,
    'staffId': staffId,
    'staffName': staffName,
    'waterQuantity': waterQuantity,
    'waterUnitPrice': waterUnitPrice,
    'racketQuantity': racketQuantity,
    'racketUnitPrice': racketUnitPrice,
    'totalRevenue': totalRevenue,
  };

  factory StaffSale.fromJson(Map<String, dynamic> json, String id) => StaffSale(
    id: id,
    bookingId: (json['bookingId'] ?? '').toString(),
    venueId: (json['venueId'] ?? '').toString(),
    dateKey: (json['dateKey'] ?? '').toString(),
    staffId: (json['staffId'] ?? '').toString(),
    staffName: (json['staffName'] ?? '').toString(),
    waterQuantity: (json['waterQuantity'] as num?)?.round() ?? 0,
    racketQuantity: (json['racketQuantity'] as num?)?.round() ?? 0,
    updatedAt: _date(json['updatedAt']) ?? DateTime.now(),
  );
}

DateTime? _date(Object? value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}
