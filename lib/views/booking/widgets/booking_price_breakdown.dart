import 'package:flutter/material.dart';

import '../../../core/utils/currency_formatter.dart';

/// Cost summary only. Payment is intentionally outside the booking flow.
class BookingPriceBreakdown extends StatelessWidget {
  final String durationLabel;
  final int hourlyPrice;
  final int finalTotal;

  const BookingPriceBreakdown({
    super.key,
    required this.durationLabel,
    required this.hourlyPrice,
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
            "Chi phí dự kiến",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          _Row(
            label: "Đơn giá sân",
            value: "${formatVnd(hourlyPrice)}đ/giờ",
          ),
          const SizedBox(height: 8), /* Hour-based duration text removed.
          _Row(label: "Thời lượng", value: "$duration giờ"),
          */ _Row(label: 'Thời lượng', value: durationLabel),
          const SizedBox(height: 10),
          const Divider(color: Color(0xFFE2E8F0)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Tổng chi phí sân",
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
