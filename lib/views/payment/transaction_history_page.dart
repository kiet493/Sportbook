import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/currency_formatter.dart';
import '../../providers/payment_providers.dart';
import '../../providers/registration_providers.dart';

class TransactionHistoryPage extends ConsumerWidget {
  final VoidCallback onBack;

  const TransactionHistoryPage({super.key, required this.onBack});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider)?.user;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Vui lòng đăng nhập.')));
    }

    final transactions = ref.watch(transactionsProvider(user.id));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Lịch sử thanh toán'),
      ),
      body: transactions.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Không tải được giao dịch: $error')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('Chưa có giao dịch.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (_, index) {
              final item = items[index];
              final couponLabel = item.couponCode.isEmpty
                  ? ''
                  : ' • ${item.couponCode}';
              final status = _transactionStatus(item.status);

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.receipt_long),
                  title: Text('${formatVnd(item.amount)}đ'),
                  subtitle: Text(
                    '${item.method == 'vnpay' ? 'VNPay' : item.method}$couponLabel',
                  ),
                  trailing: Text(status.$1, style: TextStyle(color: status.$2)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

(String, Color) _transactionStatus(String status) => switch (status) {
  'paid' => ('Đã thanh toán', const Color(0xFF16A34A)),
  'pending' => ('Đang chờ', const Color(0xFFD97706)),
  'failed' => ('Thất bại', const Color(0xFFDC2626)),
  'expired' => ('Hết hạn', const Color(0xFF64748B)),
  _ => ('Chưa xác định', const Color(0xFF64748B)),
};
