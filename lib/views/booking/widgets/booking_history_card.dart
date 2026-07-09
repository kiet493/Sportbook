import 'package:flutter/material.dart';

import '../../../models/venue.dart';
import 'booking_status_badge.dart';

class BookingHistoryCard extends StatelessWidget {
  final BookingInfo booking;
  final ValueChanged<BookingInfo> onViewDetail;

  const BookingHistoryCard({
    super.key,
    required this.booking,
    required this.onViewDetail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BookingVenueThumbnail(image: booking.venue.image),
                const SizedBox(width: 12),
                Expanded(child: _BookingHistoryCardInfo(booking: booking)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  booking.amount,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2563EB),
                  ),
                ),
                _BookingHistoryCardActions(
                  booking: booking,
                  onViewDetail: onViewDetail,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingVenueThumbnail extends StatelessWidget {
  final String image;

  const _BookingVenueThumbnail({required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(image: NetworkImage(image), fit: BoxFit.cover),
      ),
    );
  }
}

class _BookingHistoryCardInfo extends StatelessWidget {
  final BookingInfo booking;

  const _BookingHistoryCardInfo({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                booking.venue.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
            BookingStatusBadge(status: booking.status),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          "${booking.venue.sport[0]} • ${booking.court}",
          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 6),
        _BookingMetaRow(icon: Icons.calendar_today, value: booking.date),
        const SizedBox(height: 2),
        _BookingMetaRow(icon: Icons.access_time, value: booking.time),
      ],
    );
  }
}

class _BookingMetaRow extends StatelessWidget {
  final IconData icon;
  final String value;

  const _BookingMetaRow({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 10, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
      ],
    );
  }
}

class _BookingHistoryCardActions extends StatelessWidget {
  final BookingInfo booking;
  final ValueChanged<BookingInfo> onViewDetail;

  const _BookingHistoryCardActions({
    required this.booking,
    required this.onViewDetail,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (booking.status == "upcoming") ...[
          _BookingActionButton(
            label: "Hủy",
            foregroundColor: const Color(0xFFEF4444),
            borderColor: const Color(0xFFFEE2E2),
            backgroundColor: const Color(0xFFFEF2F2),
            onPressed: () {},
          ),
          const SizedBox(width: 6),
        ],
        if (booking.status != "cancelled") ...[
          _BookingActionButton(
            label: "Đặt lại",
            foregroundColor: const Color(0xFF2563EB),
            borderColor: const Color(0xFFDBEAFE),
            backgroundColor: const Color(0xFFEFF6FF),
            onPressed: () {},
          ),
          const SizedBox(width: 6),
        ],
        ElevatedButton(
          onPressed: () => onViewDetail(booking),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            minimumSize: const Size(0, 32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            "Chi tiết",
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class _BookingActionButton extends StatelessWidget {
  final String label;
  final Color foregroundColor;
  final Color borderColor;
  final Color backgroundColor;
  final VoidCallback onPressed;

  const _BookingActionButton({
    required this.label,
    required this.foregroundColor,
    required this.borderColor,
    required this.backgroundColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: foregroundColor,
        side: BorderSide(color: borderColor),
        backgroundColor: backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        minimumSize: const Size(0, 32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
