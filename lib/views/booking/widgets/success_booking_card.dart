import 'package:flutter/material.dart';

import '../../../models/venue.dart';

/// One row in the success detail list: icon (in soft blue square) +
/// label + value (optionally rendered in green).
class SuccessDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isGreenText;

  const SuccessDetailRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.isGreenText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB).withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 14,
            color: const Color(0xFF2563EB),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isGreenText
                ? const Color(0xFF15803D)
                : const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}

/// Card summarising the confirmed booking with persisted booking details.
class SuccessBookingCard extends StatelessWidget {
  final String bookingId;
  final Venue venue;
  final String court;
  final String date;
  final String timeRange;
  final String totalPrice;

  const SuccessBookingCard({
    super.key,
    required this.bookingId,
    required this.venue,
    required this.court,
    required this.date,
    required this.timeRange,
    required this.totalPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Mã đặt sân",
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  Text(
                    "#$bookingId",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: NetworkImage(venue.image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFE2E8F0), height: 1.0, thickness: 1.0),
          const SizedBox(height: 16),
          SuccessDetailRow(
            icon: Icons.location_on,
            label: "Sân",
            value: venue.name,
          ),
          const SizedBox(height: 10),
          SuccessDetailRow(
            icon: Icons.calendar_today,
            label: "Ngày",
            value: date,
          ),
          const SizedBox(height: 10),
          SuccessDetailRow(
            icon: Icons.access_time,
            label: "Giờ",
            value: timeRange,
          ),
          const SizedBox(height: 10),
          SuccessDetailRow(
            icon: Icons.sports_tennis,
            label: "Sân con",
            value: court,
          ),
          const SizedBox(height: 10),
          SuccessDetailRow(
            icon: Icons.flash_on,
            label: "Môn",
            value: venue.sport.isNotEmpty ? venue.sport[0] : "—",
          ),
          const SizedBox(height: 10),
          SuccessDetailRow(
            icon: Icons.payments_outlined,
            label: "Chi phí sân",
            value: totalPrice,
            isGreenText: true,
          ),
        ],
      ),
    );
  }
}
