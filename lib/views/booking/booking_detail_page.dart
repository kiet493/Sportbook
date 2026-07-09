import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/status_badge.dart';
import '../../models/venue.dart';
import 'widgets/booking_action_buttons.dart';
import 'widgets/booking_info_card.dart';
import 'widgets/qr_code_card.dart';
import 'widgets/timeline_card.dart';
import 'widgets/timeline_helpers.dart';
import 'widgets/venue_card.dart';

/// Detail view for a single [BookingInfo]. Composition only — every
/// visual block is delegated to a child widget under `widgets/`.
///
/// `onBack` is optional; when null the page falls back to
/// `Navigator.maybePop`. Cancel/rebook/contact are not wired yet and
/// should be connected via a `BookingDetailViewModel` later.
class BookingDetailPage extends StatelessWidget {
  final BookingInfo booking;
  final VoidCallback? onBack;
  final VoidCallback? onCancel;
  final VoidCallback? onRebook;
  final VoidCallback? onContact;

  const BookingDetailPage({
    super.key,
    required this.booking,
    this.onBack,
    this.onCancel,
    this.onRebook,
    this.onContact,
  });

  @override
  Widget build(BuildContext context) {
    final timeline = buildBookingTimeline(status: booking.status);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0.5,
        leading: BackChevronButton(onPressed: onBack),
        title: const Text(
          'Chi tiết đặt sân',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: StatusBadge(status: booking.status),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            VenueCard(venue: booking.venue),
            const SizedBox(height: 16),
            TimelineCard(steps: timeline),
            const SizedBox(height: 16),
            BookingInfoCard.fromBooking(
              id: booking.id,
              venue: booking.venue,
              court: booking.court,
              date: booking.date,
              time: booking.time,
              amount: booking.amount,
            ),
            const SizedBox(height: 16),
            const QrCodeCard(),
            const SizedBox(height: 24),
            BookingActionButtons(
              status: booking.status,
              onCancel: onCancel,
              onRebook: onRebook,
              onContact: onContact,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
