import 'package:flutter/material.dart';

import '../../../core/utils/currency_formatter.dart';

/// Itemized price card: base + service fee + discount (optional) + total.
class BookingPriceBreakdown extends StatelessWidget {
  final int duration;
  final int total;
  final int serviceFee;
  final int discount;
  final int finalTotal;

  const BookingPriceBreakdown({
    super.key,
    required this.duration,
    required this.total,
    required this.serviceFee,
    required this.discount,
    required this.finalTotal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Chi tiết thanh toán",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          _Row(label: "Phí sân (${duration}h)", value: "${formatVnd(total)}đ"),
          const SizedBox(height: 8),
          _Row(
            label: "Phí dịch vụ (5%)",
            value: "${formatVnd(serviceFee)}đ",
          ),
          if (discount > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Giảm giá voucher",
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFFEF4444),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "-${formatVnd(discount)}đ",
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFEF4444),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          const Divider(color: Color(0xFFE2E8F0)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Tổng cộng",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                "${formatVnd(finalTotal)}đ",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF2563EB),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;

  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}
