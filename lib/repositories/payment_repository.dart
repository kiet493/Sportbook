import '../models/court_booking.dart';
import '../models/payment_models.dart';
import '../services/Firebase/payment_firestore_service.dart';

class PaymentValidationException implements Exception {
  final String message;

  const PaymentValidationException(this.message);

  @override
  String toString() => message;
}

class PaymentRepository {
  final PaymentFirestoreService _service;

  const PaymentRepository(this._service);

  Stream<List<Coupon>> watchCoupons() => _service.watchCoupons();

  Stream<List<PaymentTransaction>> watchTransactions(String userId) =>
      _service.watchTransactions(userId);

  Stream<PaymentTransaction?> watchTransaction(String transactionId) =>
      _service.watchTransaction(transactionId);

  Stream<VnpayPaymentStatus?> watchPayment(String paymentId) =>
      _service.watchPayment(paymentId);

  Future<VnpayPaymentSession> createVnpayPayment({
    required List<CourtBooking> bookings,
    Coupon? coupon,
  }) {
    if (bookings.isEmpty ||
        bookings.any(
          (booking) => booking.id.isEmpty || booking.totalPrice <= 0,
        )) {
      throw const PaymentValidationException(
        'Thông tin booking không hợp lệ để thanh toán.',
      );
    }
    if (bookings.any(
      (booking) => booking.status == CourtSlotStatus.cancelled,
    )) {
      throw const PaymentValidationException(
        'Không thể thanh toán vì có booking đã hủy.',
      );
    }
    final subtotal = bookings.fold<int>(
      0,
      (total, booking) => total + booking.totalPrice,
    );
    if (coupon != null && !coupon.isApplicableTo(subtotal, DateTime.now())) {
      throw const PaymentValidationException('Mã giảm giá không còn hợp lệ.');
    }
    return _service.createVnpayPayment(
      bookingIds: bookings.map((booking) => booking.id).toList(growable: false),
      couponId: coupon?.id,
    );
  }
}
