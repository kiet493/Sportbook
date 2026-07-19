import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

import '../../models/payment_models.dart';
import 'firebase_functions_client.dart' as functions_client;

class VnpayCallableException implements Exception {
  const VnpayCallableException({
    required this.code,
    required this.message,
    this.details,
  });

  final String code;
  final String message;
  final Object? details;

  @override
  String toString() => message;
}

class PaymentFirestoreService {
  PaymentFirestoreService({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
  }) : _db = firestore ?? FirebaseFirestore.instance,
       _functions = functions ?? functions_client.functions;

  final FirebaseFirestore _db;
  final FirebaseFunctions _functions;

  Stream<List<Coupon>> watchCoupons() =>
      _db.collection('coupons').snapshots().map((snapshot) {
        final now = DateTime.now();
        final items = snapshot.docs
            .map((doc) => Coupon.fromJson(doc.data(), doc.id))
            .where(
              (item) =>
                  item.active &&
                  (item.expiresAt == null || item.expiresAt!.isAfter(now)),
            )
            .toList();
        items.sort((a, b) => a.code.compareTo(b.code));
        return items;
      });

  Stream<List<PaymentTransaction>> watchTransactions(String userId) => _db
      .collection('transactions')
      .where('userId', isEqualTo: userId)
      .snapshots()
      .map((snapshot) {
        final items = snapshot.docs
            .map((doc) => PaymentTransaction.fromJson(doc.data(), doc.id))
            .toList();
        items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return items;
      });

  Stream<PaymentTransaction?> watchTransaction(String transactionId) => _db
      .collection('transactions')
      .doc(transactionId)
      .snapshots()
      .map(
        (snapshot) => snapshot.exists && snapshot.data() != null
            ? PaymentTransaction.fromJson(snapshot.data()!, snapshot.id)
            : null,
      );

  Stream<VnpayPaymentStatus?> watchPayment(String paymentId) => _db
      .collection('payments')
      .doc(paymentId)
      .snapshots()
      .map(
        (snapshot) => snapshot.exists && snapshot.data() != null
            ? VnpayPaymentStatus.fromJson(snapshot.data()!, snapshot.id)
            : null,
      );

  Future<VnpayPaymentSession> createVnpayPayment({
    required List<String> bookingIds,
    String? couponId,
  }) async {
    final normalizedBookingIds = bookingIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList(growable: false);
    if (normalizedBookingIds.isEmpty) {
      throw const FormatException(
        'Không xác định được booking cần thanh toán.',
      );
    }
    final normalizedCouponId = couponId?.trim();
    try {
      if (kDebugMode) {
        debugPrint(
          'Calling createVnpayPayment through Functions Emulator '
          'at 127.0.0.1:5001, region asia-southeast1',
        );
      }
      final callable = _functions.httpsCallable('createVnpayPayment');
      final result = await callable.call(<String, Object?>{
        'bookingId': normalizedBookingIds.first,
        'bookingIds': normalizedBookingIds,
        if (normalizedCouponId != null && normalizedCouponId.isNotEmpty)
          'couponId': normalizedCouponId,
      });
      if (result.data is! Map) {
        throw const FormatException(
          'Máy chủ VNPay trả về dữ liệu không hợp lệ.',
        );
      }
      return VnpayPaymentSession.fromJson(
        Map<String, dynamic>.from(result.data as Map),
      );
    } on FirebaseFunctionsException catch (error) {
      if (_isLocalFunctionsConnectionError(error)) {
        throw const VnpayCallableException(
          code: 'unavailable',
          message:
              'Không kết nối được máy chủ thanh toán local. '
              'Hãy kiểm tra Functions Emulator.',
        );
      }
      throw VnpayCallableException(
        code: error.code,
        message: error.message?.trim().isNotEmpty == true
            ? error.message!.trim()
            : 'Cloud Function không trả về thông báo lỗi.',
        details: error.details,
      );
    } on FormatException {
      rethrow;
    } catch (error) {
      if (_isLocalFunctionsConnectionError(error)) {
        throw const VnpayCallableException(
          code: 'unavailable',
          message:
              'Không kết nối được máy chủ thanh toán local. '
              'Hãy kiểm tra Functions Emulator.',
        );
      }
      throw const VnpayCallableException(
        code: 'client-error',
        message: 'Không thể gửi yêu cầu thanh toán đến máy chủ.',
      );
    }
  }
}

bool _isLocalFunctionsConnectionError(Object error) {
  if (!kDebugMode) return false;
  if (error is FirebaseFunctionsException) {
    if (error.code == 'unavailable') return true;
    if (error.code == 'internal' &&
        (error.message == null ||
            error.message!.trim().isEmpty ||
            error.message!.trim().toLowerCase() == 'internal')) {
      return true;
    }
  }

  final text = error.toString().toLowerCase();
  return text.contains('connection refused') ||
      text.contains('err_connection_refused') ||
      text.contains('failed to fetch') ||
      text.contains('xmlhttprequest error') ||
      text.contains('network request failed');
}
