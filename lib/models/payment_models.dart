import 'package:cloud_firestore/cloud_firestore.dart';

class Coupon {
  final String id;
  final String code;
  final String title;
  final int discountAmount;
  final int minOrder;
  final bool active;
  final DateTime? expiresAt;

  const Coupon({
    required this.id,
    required this.code,
    required this.title,
    required this.discountAmount,
    required this.minOrder,
    required this.active,
    this.expiresAt,
  });

  bool isApplicableTo(int amount, DateTime now) =>
      active &&
      amount >= minOrder &&
      (expiresAt == null || expiresAt!.isAfter(now));

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

class VnpayPaymentSession {
  final String paymentId;
  final String transactionId;
  final Uri paymentUrl;
  final int amount;
  final int discount;
  final String couponCode;
  final DateTime expiresAt;
  final bool reused;

  const VnpayPaymentSession({
    required this.paymentId,
    required this.transactionId,
    required this.paymentUrl,
    required this.amount,
    required this.discount,
    required this.couponCode,
    required this.expiresAt,
    required this.reused,
  });

  bool get expired => !expiresAt.isAfter(DateTime.now());

  factory VnpayPaymentSession.fromJson(Map<String, dynamic> data) {
    final paymentId = (data['paymentId'] ?? '').toString();
    final transactionId = (data['transactionId'] ?? '').toString();
    final paymentUrl = Uri.tryParse((data['paymentUrl'] ?? '').toString());
    final expiresAt = _date(data['expiresAt']);
    if (paymentId.isEmpty ||
        transactionId.isEmpty ||
        paymentUrl == null ||
        !paymentUrl.hasScheme ||
        expiresAt == null) {
      throw const FormatException(
        'Phản hồi tạo thanh toán VNPay không hợp lệ.',
      );
    }
    return VnpayPaymentSession(
      paymentId: paymentId,
      transactionId: transactionId,
      paymentUrl: paymentUrl,
      amount: (data['amount'] as num?)?.round() ?? 0,
      discount: (data['discount'] as num?)?.round() ?? 0,
      couponCode: (data['couponCode'] ?? '').toString(),
      expiresAt: expiresAt,
      reused: data['reused'] == true,
    );
  }
}

class VnpayPaymentStatus {
  final String id;
  final String bookingId;
  final String transactionId;
  final String status;
  final String responseCode;

  const VnpayPaymentStatus({
    required this.id,
    required this.bookingId,
    required this.transactionId,
    required this.status,
    required this.responseCode,
  });

  bool get isPaid => status == 'paid';
  bool get isPending => status == 'pending';

  factory VnpayPaymentStatus.fromJson(Map<String, dynamic> data, String id) =>
      VnpayPaymentStatus(
        id: id,
        bookingId: (data['bookingId'] ?? '').toString(),
        transactionId: (data['transactionId'] ?? '').toString(),
        status: (data['status'] ?? '').toString(),
        responseCode: (data['vnpResponseCode'] ?? '').toString(),
      );
}

class PaymentTransaction {
  final String id;
  final String paymentId;
  final String bookingId;
  final String userId;
  final int amount;
  final int discount;
  final String method;
  final String status;
  final String couponCode;
  final String vnpayTransactionNo;
  final String responseCode;
  final DateTime createdAt;

  const PaymentTransaction({
    required this.id,
    this.paymentId = '',
    required this.bookingId,
    required this.userId,
    required this.amount,
    required this.discount,
    required this.method,
    required this.status,
    required this.couponCode,
    this.vnpayTransactionNo = '',
    this.responseCode = '',
    required this.createdAt,
  });

  bool get isPaid => status == 'paid';
  bool get isPending => status == 'pending';

  factory PaymentTransaction.fromJson(Map<String, dynamic> data, String id) =>
      PaymentTransaction(
        id: id,
        paymentId: (data['paymentId'] ?? '').toString(),
        bookingId: (data['bookingId'] ?? '').toString(),
        userId: (data['userId'] ?? '').toString(),
        amount: (data['amount'] as num?)?.round() ?? 0,
        discount: (data['discount'] as num?)?.round() ?? 0,
        method: (data['method'] ?? '').toString(),
        status: (data['status'] ?? '').toString(),
        couponCode: (data['couponCode'] ?? '').toString(),
        vnpayTransactionNo: (data['vnpTransactionNo'] ?? '').toString(),
        responseCode: (data['vnpResponseCode'] ?? '').toString(),
        createdAt: _date(data['createdAt']) ?? DateTime.now(),
      );
}

DateTime? _date(Object? value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}
