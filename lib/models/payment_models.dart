import 'package:cloud_firestore/cloud_firestore.dart';

class Coupon {
  final String id;
  final String code;
  final String title;
  final int discountAmount;
  final int minOrder;
  final bool active;
  final DateTime? expiresAt;

  const Coupon({required this.id, required this.code, required this.title, required this.discountAmount, required this.minOrder, required this.active, this.expiresAt});

  bool isApplicableTo(int amount, DateTime now) =>
      active && amount >= minOrder && (expiresAt == null || expiresAt!.isAfter(now));

  factory Coupon.fromJson(Map<String, dynamic> data, String id) => Coupon(
    id: id,
    code: (data['code'] ?? '').toString().trim().toUpperCase(),
    title: (data['title'] ?? '').toString(),
    discountAmount: (data['discountAmount'] as num?)?.round() ?? 0,
    minOrder: (data['minOrder'] as num?)?.round() ?? 0,
    active: data['active'] != false,
    expiresAt: _date(data['expiresAt']),
  );
}

class PaymentTransaction {
  final String id;
  final String bookingId;
  final String userId;
  final int amount;
  final int discount;
  final String method;
  final String status;
  final String couponCode;
  final DateTime createdAt;

  const PaymentTransaction({required this.id, required this.bookingId, required this.userId, required this.amount, required this.discount, required this.method, required this.status, required this.couponCode, required this.createdAt});

  factory PaymentTransaction.fromJson(Map<String, dynamic> data, String id) => PaymentTransaction(
    id: id,
    bookingId: (data['bookingId'] ?? '').toString(),
    userId: (data['userId'] ?? '').toString(),
    amount: (data['amount'] as num?)?.round() ?? 0,
    discount: (data['discount'] as num?)?.round() ?? 0,
    method: (data['method'] ?? '').toString(),
    status: (data['status'] ?? '').toString(),
    couponCode: (data['couponCode'] ?? '').toString(),
    createdAt: _date(data['createdAt']) ?? DateTime.now(),
  );
}

DateTime? _date(Object? value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}
