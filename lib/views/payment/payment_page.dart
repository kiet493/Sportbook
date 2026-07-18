import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/court_booking.dart';
import '../../models/payment_models.dart';
import '../../providers/payment_providers.dart';
import '../../providers/registration_providers.dart';

class PaymentPage extends ConsumerStatefulWidget {
  final CourtBooking booking;
  final VoidCallback onBack;
  final ValueChanged<PaymentTransaction> onPaid;
  const PaymentPage({super.key, required this.booking, required this.onBack, required this.onPaid});
  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage> {
  String _method = 'cash';
  Coupon? _coupon;
  bool _loading = false;

  int get _discount => _coupon?.isApplicableTo(widget.booking.totalPrice, DateTime.now()) == true ? _coupon!.discountAmount.clamp(0, widget.booking.totalPrice).toInt() : 0;

  Future<void> _pay() async {
    final user = ref.read(sessionProvider)?.user;
    if (user == null) return;
    setState(() => _loading = true);
    try {
      final payment = await ref.read(paymentFirestoreServiceProvider).pay(bookingId: widget.booking.id, userId: user.id, subtotal: widget.booking.totalPrice, method: _method, coupon: _coupon);
      if (mounted) widget.onPaid(payment);
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không thể thanh toán lúc này.')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final coupons = ref.watch(couponsProvider);
    final total = widget.booking.totalPrice - _discount;
    return Scaffold(
      appBar: AppBar(leading: IconButton(onPressed: widget.onBack, icon: const Icon(Icons.arrow_back)), title: const Text('Thanh toán')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Card(child: ListTile(title: Text(widget.booking.venueName), subtitle: Text('${widget.booking.courtName}\n${widget.booking.timeRange}'), trailing: Text('${formatVnd(widget.booking.totalPrice)}đ', style: const TextStyle(fontWeight: FontWeight.bold)))),
        const SizedBox(height: 16),
        const Text('Phương thức thanh toán', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        for (final item in const [('cash', 'Tiền mặt tại sân'), ('momo', 'MoMo'), ('vnpay', 'VNPay'), ('card', 'Thẻ ngân hàng')]) RadioListTile<String>(value: item.$1, groupValue: _method, title: Text(item.$2), onChanged: (value) => setState(() => _method = value!)),
        const SizedBox(height: 12),
        const Text('Mã giảm giá', style: TextStyle(fontWeight: FontWeight.bold)),
        coupons.when(
          loading: () => const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator()),
          error: (_, _) => const Text('Không tải được coupon.'),
          data: (items) => items.isEmpty ? const Padding(padding: EdgeInsets.only(top: 8), child: Text('Chưa có mã giảm giá khả dụng.')) : Wrap(spacing: 8, children: [for (final item in items) ChoiceChip(label: Text(item.code), selected: _coupon?.id == item.id, onSelected: (_) => setState(() => _coupon = _coupon?.id == item.id ? null : item))]),
        ),
        const SizedBox(height: 20),
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
          _row('Tạm tính', widget.booking.totalPrice),
          _row('Giảm giá', -_discount),
          const Divider(),
          _row('Thanh toán', total, bold: true),
        ]))),
        const SizedBox(height: 20),
        FilledButton(onPressed: _loading ? null : _pay, style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)), child: _loading ? const CircularProgressIndicator() : Text('Thanh toán ${formatVnd(total)}đ')),
      ]),
    );
  }
  Widget _row(String label, int amount, {bool bold = false}) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: TextStyle(fontWeight: bold ? FontWeight.bold : null)), Text('${amount < 0 ? '-' : ''}${formatVnd(amount.abs())}đ', style: TextStyle(fontWeight: bold ? FontWeight.bold : null))]);
}
