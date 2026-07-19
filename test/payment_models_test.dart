import 'package:flutter_test/flutter_test.dart';
import 'package:sportbook/models/payment_models.dart';
import 'package:sportbook/providers/payment_providers.dart';
import 'package:sportbook/services/Firebase/payment_firestore_service.dart';

void main() {
  test('VNPay checkout session parses callable response', () {
    final session = VnpayPaymentSession.fromJson({
      'paymentId': 'payment-1',
      'transactionId': 'transaction-1',
      'paymentUrl':
          'https://sandbox.vnpayment.vn/paymentv2/vpcpay.html?vnp_TxnRef=payment-1',
      'amount': 150000,
      'discount': 10000,
      'couponCode': 'SPORT10',
      'expiresAt': '2026-07-19T12:30:00.000Z',
      'reused': false,
    });

    expect(session.paymentId, 'payment-1');
    expect(session.transactionId, 'transaction-1');
    expect(session.paymentUrl.host, 'sandbox.vnpayment.vn');
    expect(session.amount, 150000);
    expect(session.discount, 10000);
    expect(session.couponCode, 'SPORT10');
  });

  test('payment transaction reads VNPay confirmation fields', () {
    final transaction = PaymentTransaction.fromJson({
      'paymentId': 'payment-1',
      'bookingId': 'booking-1',
      'userId': 'user-1',
      'amount': 150000,
      'discount': 10000,
      'method': 'vnpay',
      'status': 'paid',
      'couponCode': 'SPORT10',
      'vnpTransactionNo': '14985210',
      'vnpResponseCode': '00',
      'createdAt': '2026-07-19T12:00:00.000Z',
    }, 'transaction-1');

    expect(transaction.isPaid, isTrue);
    expect(transaction.vnpayTransactionNo, '14985210');
    expect(transaction.responseCode, '00');
  });

  test('payment status reads the local return confirmation', () {
    final payment = VnpayPaymentStatus.fromJson({
      'bookingId': 'booking-1',
      'transactionId': 'transaction-1',
      'status': 'paid',
      'vnpResponseCode': '00',
    }, 'payment-1');

    expect(payment.isPaid, isTrue);
    expect(payment.bookingId, 'booking-1');
    expect(payment.transactionId, 'transaction-1');
    expect(payment.responseCode, '00');
  });

  test('checkout session rejects incomplete server response', () {
    expect(
      () => VnpayPaymentSession.fromJson({'paymentId': 'payment-1'}),
      throwsFormatException,
    );
  });

  test('callable internal error is shown as a useful message', () {
    const error = VnpayCallableException(code: 'internal', message: 'internal');

    expect(
      vnpayCheckoutErrorMessage(error),
      'Máy chủ thanh toán gặp lỗi nội bộ. Vui lòng thử lại.',
    );
  });

  test('callable keeps the safe backend error message', () {
    const message = 'Không thể khởi tạo thanh toán VNPay. Vui lòng thử lại.';
    const error = VnpayCallableException(code: 'internal', message: message);

    expect(vnpayCheckoutErrorMessage(error), message);
  });

  test('callable unavailable error points to the local emulator', () {
    const error = VnpayCallableException(
      code: 'unavailable',
      message: 'unavailable',
    );

    expect(
      vnpayCheckoutErrorMessage(error),
      'Không kết nối được máy chủ thanh toán local. '
      'Hãy kiểm tra Functions Emulator.',
    );
  });
}
