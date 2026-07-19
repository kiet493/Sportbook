import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/utils/currency_formatter.dart';
import '../../models/court_booking.dart';
import '../../models/payment_models.dart';
import '../../providers/payment_providers.dart';

class PaymentPage extends ConsumerStatefulWidget {
  final CourtBooking booking;
  final VoidCallback onBack;
  final ValueChanged<PaymentTransaction> onPaid;

  const PaymentPage({
    super.key,
    required this.booking,
    required this.onBack,
    required this.onPaid,
  });

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage> {
  Coupon? _coupon;
  String? _launchError;

  int get _discount =>
      _coupon?.isApplicableTo(widget.booking.totalPrice, DateTime.now()) == true
      ? _coupon!.discountAmount.clamp(0, widget.booking.totalPrice).toInt()
      : 0;

  Future<void> _startPayment() async {
    setState(() => _launchError = null);
    final session = await ref
        .read(vnpayCheckoutProvider.notifier)
        .start(booking: widget.booking, coupon: _coupon);
    if (!mounted) return;
    if (session == null) {
      final error = ref.read(vnpayCheckoutProvider).error;
      setState(() => _launchError = vnpayCheckoutErrorMessage(error));
      return;
    }
    await _openVnpay(session.paymentUrl);
  }

  Future<void> _openVnpay(Uri paymentUrl) async {
    final opened = await launchUrl(
      paymentUrl,
      mode: LaunchMode.platformDefault,
      webOnlyWindowName: '_blank',
    );
    if (!mounted || opened) return;
    setState(() {
      _launchError = 'Không thể mở cổng VNPay. Vui lòng cho phép mở tab mới.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final coupons = ref.watch(couponsProvider);
    final checkout = ref.watch(vnpayCheckoutProvider);
    final session = checkout.valueOrNull;
    final paymentStatus = session == null
        ? null
        : ref.watch(paymentByIdProvider(session.paymentId)).valueOrNull;
    final canOpenExistingSession =
        session != null &&
        !session.expired &&
        (paymentStatus == null || paymentStatus.isPending);
    final effectiveDiscount = session?.discount ?? _discount;
    final total = session?.amount ?? widget.booking.totalPrice - _discount;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          onPressed: widget.onBack,
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Thanh toán VNPay'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                widget.booking.venueName,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(
                '${widget.booking.courtName}\n${widget.booking.timeRange}',
              ),
              trailing: Text(
                '${formatVnd(widget.booking.totalPrice)}đ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const _VnpayMethodCard(),
          const SizedBox(height: 16),
          const Text(
            'Mã giảm giá',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          coupons.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => const Text('Không tải được coupon.'),
            data: (items) => items.isEmpty
                ? const Text('Chưa có mã giảm giá khả dụng.')
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final item in items)
                        ChoiceChip(
                          label: Text(item.code),
                          selected: _coupon?.id == item.id,
                          onSelected: session != null || checkout.isLoading
                              ? null
                              : (_) {
                                  setState(() {
                                    _coupon = _coupon?.id == item.id
                                        ? null
                                        : item;
                                    _launchError = null;
                                  });
                                },
                        ),
                    ],
                  ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _amountRow('Tạm tính', widget.booking.totalPrice),
                  const SizedBox(height: 10),
                  _amountRow('Giảm giá', -effectiveDiscount),
                  const Divider(height: 24),
                  _amountRow('Thanh toán', total, bold: true),
                ],
              ),
            ),
          ),
          if (session != null) ...[
            const SizedBox(height: 16),
            if (session.reused)
              Text(
                session.couponCode.isEmpty
                    ? 'Đang sử dụng lại giao dịch VNPay chưa hết hạn.'
                    : 'Đang sử dụng lại giao dịch với mã ${session.couponCode}.',
                style: const TextStyle(color: Color(0xFF64748B)),
              ),
            _VnpayTransactionStatus(session: session, onPaid: widget.onPaid),
          ],
          if (_launchError != null) ...[
            const SizedBox(height: 12),
            Text(
              _launchError!,
              style: const TextStyle(color: Color(0xFFDC2626)),
            ),
          ],
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: checkout.isLoading
                ? null
                : () => canOpenExistingSession
                      ? _openVnpay(session.paymentUrl)
                      : _startPayment(),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
              backgroundColor: const Color(0xFF005BAA),
            ),
            icon: checkout.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.open_in_new),
            label: Text(
              session == null
                  ? 'Thanh toán ${formatVnd(total)}đ qua VNPay'
                  : canOpenExistingSession
                  ? 'Mở lại cổng VNPay'
                  : 'Tạo giao dịch VNPay mới',
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Cổng Sandbox sẽ mở ở tab khác. Khi chạy local, trang VNPay Return '
            'sẽ xác minh và cập nhật trạng thái thanh toán; quay lại SportBook '
            'nếu tab không tự đóng.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _amountRow(String label, int amount, {bool bold = false}) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: TextStyle(fontWeight: bold ? FontWeight.bold : null)),
      Text(
        '${amount < 0 ? '-' : ''}${formatVnd(amount.abs())}đ',
        style: TextStyle(fontWeight: bold ? FontWeight.bold : null),
      ),
    ],
  );
}

class _VnpayMethodCard extends StatelessWidget {
  const _VnpayMethodCard();

  @override
  Widget build(BuildContext context) => Card(
    color: const Color(0xFFEFF6FF),
    child: const ListTile(
      contentPadding: EdgeInsets.all(16),
      leading: CircleAvatar(
        backgroundColor: Color(0xFF005BAA),
        child: Icon(Icons.account_balance, color: Colors.white),
      ),
      title: Text(
        'VNPay Sandbox',
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
      subtitle: Text('ATM nội địa, thẻ quốc tế hoặc VNPAY-QR'),
      trailing: Icon(Icons.check_circle, color: Color(0xFF16A34A)),
    ),
  );
}

class _VnpayTransactionStatus extends ConsumerStatefulWidget {
  final VnpayPaymentSession session;
  final ValueChanged<PaymentTransaction> onPaid;

  const _VnpayTransactionStatus({required this.session, required this.onPaid});

  @override
  ConsumerState<_VnpayTransactionStatus> createState() =>
      _VnpayTransactionStatusState();
}

class _VnpayTransactionStatusState
    extends ConsumerState<_VnpayTransactionStatus>
    with WidgetsBindingObserver {
  bool _notified = false;
  Timer? _expiryTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scheduleExpiryCheck();
  }

  @override
  void didUpdateWidget(covariant _VnpayTransactionStatus oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.session.transactionId != widget.session.transactionId) {
      _notified = false;
      _scheduleExpiryCheck();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshStatus();
  }

  @override
  void dispose() {
    _expiryTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _scheduleExpiryCheck() {
    _expiryTimer?.cancel();
    final remaining = widget.session.expiresAt.difference(DateTime.now());
    if (remaining <= Duration.zero) return;
    _expiryTimer = Timer(remaining, () {
      if (!mounted) return;
      setState(() {});
      _refreshStatus();
    });
  }

  void _refreshStatus() {
    if (!mounted) return;
    ref.invalidate(paymentByIdProvider(widget.session.paymentId));
    ref.invalidate(transactionByIdProvider(widget.session.transactionId));
  }

  Widget _withRefresh(Widget statusCard) => Column(
    children: [
      statusCard,
      const SizedBox(height: 8),
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _refreshStatus,
          icon: const Icon(Icons.refresh),
          label: const Text('Kiểm tra trạng thái'),
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final transaction = ref.watch(
      transactionByIdProvider(widget.session.transactionId),
    );
    final payment = ref.watch(paymentByIdProvider(widget.session.paymentId));
    final transactionValue = transaction.valueOrNull;
    final paymentValue = payment.valueOrNull;

    if (transactionValue?.isPaid == true && !_notified) {
      _notified = true;
      _expiryTimer?.cancel();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onPaid(transactionValue!);
      });
    }
    if (transactionValue?.isPaid == true || paymentValue?.isPaid == true) {
      _expiryTimer?.cancel();
      return const _StatusCard(
        icon: Icons.check_circle_outline,
        color: Color(0xFF16A34A),
        title: 'Thanh toán thành công',
        message: 'Trạng thái đơn đặt sân đã được cập nhật.',
      );
    }

    if (transaction.isLoading && payment.isLoading) {
      return _withRefresh(
        const _StatusCard(
          icon: Icons.sync,
          color: Color(0xFFD97706),
          title: 'Đang chờ thanh toán',
          message: 'SportBook đang chờ kết quả xác nhận từ VNPay.',
        ),
      );
    }
    if (transaction.hasError &&
        payment.hasError &&
        transactionValue == null &&
        paymentValue == null) {
      return _withRefresh(
        const _StatusCard(
          icon: Icons.cloud_off_outlined,
          color: Color(0xFFDC2626),
          title: 'Chưa tải được trạng thái',
          message: 'Hãy kiểm tra kết nối Firestore rồi thử lại.',
        ),
      );
    }

    final status =
        paymentValue?.status ?? transactionValue?.status ?? 'pending';
    final responseCode = paymentValue?.responseCode.isNotEmpty == true
        ? paymentValue!.responseCode
        : transactionValue?.responseCode ?? '';
    if (status != 'pending') {
      return _withRefresh(
        _StatusCard(
          icon: Icons.error_outline,
          color: const Color(0xFFDC2626),
          title: status == 'cancelled'
              ? 'Thanh toán đã bị hủy'
              : 'Thanh toán chưa thành công',
          message: responseCode.isEmpty
              ? 'Giao dịch đã hết hạn, thất bại hoặc bị hủy.'
              : 'Mã phản hồi VNPay: $responseCode',
        ),
      );
    }
    return _withRefresh(
      _StatusCard(
        icon: Icons.schedule,
        color: const Color(0xFFD97706),
        title: 'Đang chờ VNPay xác nhận',
        message: widget.session.expired
            ? 'Giao dịch đã hết hạn. Hãy tạo thanh toán mới để thử lại.'
            : 'Hoàn tất ở tab VNPay rồi quay lại SportBook.',
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String message;

  const _StatusCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      contentPadding: const EdgeInsets.all(16),
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      subtitle: Text(message),
    ),
  );
}
