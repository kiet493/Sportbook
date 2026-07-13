import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/info_row.dart';
import '../../../core/widgets/section_card.dart';
import '../../../models/venue.dart';

/// Section listing booking metadata: id, court, date, time, court type, amount.
class BookingDetailInfoCard extends StatelessWidget {
  final String bookingId;
  final String court;
  final String date;
  final String time;
  final String sport;
  final String amount;

  const BookingDetailInfoCard({
    super.key,
    required this.bookingId,
    required this.court,
    required this.date,
    required this.time,
    required this.sport,
    required this.amount,
  });

  factory BookingDetailInfoCard.fromBooking({
    Key? key,
    required String id,
    required Venue venue,
    required String court,
    required String date,
    required String time,
    required String amount,
  }) {
    return BookingDetailInfoCard(
      key: key,
      bookingId: id,
      court: court,
      date: date,
      time: time,
      sport: venue.sport.isNotEmpty ? venue.sport.first : '—',
      amount: amount,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Thông tin đặt sân',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          InfoRow(label: 'Mã đặt sân', value: '#$bookingId'),
          InfoRow(label: 'Sân', value: court),
          InfoRow(label: 'Ngày', value: date),
          InfoRow(label: 'Giờ', value: time),
          InfoRow(label: 'Loại sân', value: sport),
          InfoRow(
            label: 'Số tiền',
            value: amount,
            isBoldValue: true,
            isLast: true,
          ),
        ],
      ),
    );
  }
}
