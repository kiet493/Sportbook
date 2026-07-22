import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/court_booking.dart';
import '../models/community_models.dart';
import '../models/payment_models.dart';
import '../repositories/payment_repository.dart';
import '../services/Firebase/payment_firestore_service.dart';

final paymentFirestoreServiceProvider = Provider<PaymentFirestoreService>(
  (ref) => PaymentFirestoreService(),
);

final paymentRepositoryProvider = Provider<PaymentRepository>(
  (ref) => PaymentRepository(ref.watch(paymentFirestoreServiceProvider)),
);

final couponsProvider = StreamProvider<List<Coupon>>(
  (ref) => ref.watch(paymentRepositoryProvider).watchCoupons(),
);

final allCouponsProvider = StreamProvider<List<Coupon>>(
  (ref) => ref.watch(paymentRepositoryProvider).watchAllCoupons(),
);

class CouponActionNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  void build() {}

  Future<String?> save(Coupon coupon) async {
    state = const AsyncLoading();
    try {
      await ref.read(paymentRepositoryProvider).saveCoupon(coupon);
      state = const AsyncData(null);
      return null;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return error.toString();
    }
  }

  Future<String?> delete(String id) async {
    state = const AsyncLoading();
    try {
      await ref.read(paymentRepositoryProvider).deleteCoupon(id);
      state = const AsyncData(null);
      return null;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return error.toString();
    }
  }
}

final couponActionProvider =
    AutoDisposeAsyncNotifierProvider<CouponActionNotifier, void>(
      CouponActionNotifier.new,
    );

final transactionsProvider =
    StreamProvider.family<List<PaymentTransaction>, String>(
      (ref, userId) =>
          ref.watch(paymentRepositoryProvider).watchTransactions(userId),
    );

final transactionByIdProvider = StreamProvider.autoDispose
    .family<PaymentTransaction?, String>(
      (ref, transactionId) =>
          ref.watch(paymentRepositoryProvider).watchTransaction(transactionId),
    );

final paymentByIdProvider = StreamProvider.autoDispose
    .family<VnpayPaymentStatus?, String>(
      (ref, paymentId) =>
          ref.watch(paymentRepositoryProvider).watchPayment(paymentId),
    );

class VnpayCheckoutNotifier
    extends AutoDisposeAsyncNotifier<VnpayPaymentSession?> {
  @override
  VnpayPaymentSession? build() => null;

  Future<VnpayPaymentSession?> start({
    required List<CourtBooking> bookings,
    Coupon? coupon,
  }) async {
    state = const AsyncLoading();
    try {
      final session = await ref
          .read(paymentRepositoryProvider)
          .createVnpayPayment(bookings: bookings, coupon: coupon);
      state = AsyncData(session);
      return session;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return null;
    }
  }

  Future<VnpayPaymentSession?> startEvent({
    required SportEvent event,
    Coupon? coupon,
  }) async {
    state = const AsyncLoading();
    try {
      final session = await ref
          .read(paymentRepositoryProvider)
          .createEventVnpayPayment(event: event, coupon: coupon);
      state = AsyncData(session);
      return session;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return null;
    }
  }
}

final vnpayCheckoutProvider =
    AutoDisposeAsyncNotifierProvider<
      VnpayCheckoutNotifier,
      VnpayPaymentSession?
    >(VnpayCheckoutNotifier.new);

String vnpayCheckoutErrorMessage(Object? error) {
  if (error is PaymentValidationException) return error.message;
  if (error is VnpayCallableException) {
    return _vnpayFunctionErrorMessage(error.code, error.message);
  }
  if (error is FirebaseFunctionsException) {
    return _vnpayFunctionErrorMessage(error.code, error.message);
  }
  if (error is FormatException) return error.message;
  return 'Không thể khởi tạo thanh toán VNPay lúc này.';
}

String _vnpayFunctionErrorMessage(String code, String? message) {
  final normalizedMessage = message?.trim();
  final serverMessage =
      normalizedMessage == null ||
          normalizedMessage.isEmpty ||
          normalizedMessage.toLowerCase() == 'internal'
      ? null
      : normalizedMessage;

  return switch (code) {
    'unauthenticated' => serverMessage ?? 'Phiên đăng nhập đã hết hạn.',
    'permission-denied' =>
      serverMessage ?? 'Bạn không có quyền thanh toán booking này.',
    'not-found' => serverMessage ?? 'Booking không còn tồn tại.',
    'already-exists' => serverMessage ?? 'Booking này đã được thanh toán.',
    'failed-precondition' ||
    'invalid-argument' => serverMessage ?? 'Thông tin thanh toán không hợp lệ.',
    'aborted' =>
      serverMessage ?? 'Dữ liệu booking vừa thay đổi. Vui lòng thử lại.',
    'resource-exhausted' =>
      serverMessage ?? 'Máy chủ thanh toán đang bận. Vui lòng thử lại sau.',
    'deadline-exceeded' =>
      serverMessage ??
          'Yêu cầu thanh toán quá thời gian chờ. Vui lòng thử lại.',
    'unavailable' =>
      'Không kết nối được máy chủ thanh toán local. '
          'Hãy kiểm tra Functions Emulator.',
    'internal' =>
      serverMessage ?? 'Máy chủ thanh toán gặp lỗi nội bộ. Vui lòng thử lại.',
    'client-error' =>
      serverMessage ?? 'Không thể gửi yêu cầu thanh toán đến máy chủ.',
    _ => serverMessage ?? 'Không thể khởi tạo thanh toán VNPay.',
  };
}
