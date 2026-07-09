import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/back_chevron_button.dart';
import '../../core/widgets/info_row.dart';
import '../../core/widgets/section_card.dart';
import '../../core/widgets/status_badge.dart';
import '../../models/booking_model.dart';
import '../../models/venue.dart';

/// Detail view for a single [BookingInfo]. Composition only — every
/// visual block lives in a private widget in this file because each
/// one is used exclusively by this page.
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
            _VenueCard(venue: booking.venue),
            const SizedBox(height: 16),
            _TimelineCard(steps: timeline),
            const SizedBox(height: 16),
            _BookingInfoCard.fromBooking(
              id: booking.id,
              venue: booking.venue,
              court: booking.court,
              date: booking.date,
              time: booking.time,
              amount: booking.amount,
            ),
            const SizedBox(height: 16),
            const _QrCodeCard(),
            const SizedBox(height: 24),
            _BookingActionButtons(
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

/// Pure function: build the [TimelineStep] list shown above the info
/// card. Kept in the views layer (not the model) because the strings
/// are UI copy and the times are presentation-only.
List<TimelineStep> buildBookingTimeline({
  required String status,
  String bookedAt = '10:23 AM',
  String paidAt = '10:24 AM',
  String confirmedAt = '10:25 AM',
}) {
  return [
    TimelineStep(label: 'Đặt sân thành công', time: bookedAt, done: true),
    TimelineStep(label: 'Thanh toán xác nhận', time: paidAt, done: true),
    TimelineStep(
      label: 'Sân đã xác nhận',
      time: confirmedAt,
      done: status != BookingStatus.cancelled,
    ),
    TimelineStep(
      label: 'Hoàn thành',
      time: status == BookingStatus.completed ? 'Đã hoàn thành' : '--',
      done: status == BookingStatus.completed,
    ),
  ];
}

/// Hero image + name/address block at the top of the booking detail page.
class _VenueCard extends StatelessWidget {
  final Venue venue;

  const _VenueCard({required this.venue});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      padding: EdgeInsets.zero,
      radius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 140,
            child: Image.network(venue.image, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  venue.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: AppColors.textSecondary,
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        venue.address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Vertical stepper showing booking progress (booked → paid → confirmed → done).
///
/// Renders a connected dot for each [TimelineStep]. Future steps are muted;
/// completed steps are brand-blue with a check icon.
class _TimelineCard extends StatelessWidget {
  final List<TimelineStep> steps;

  const _TimelineCard({required this.steps});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Trạng thái đặt sân',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: List.generate(steps.length, (index) {
              final step = steps[index];
              final isLast = index == steps.length - 1;
              final nextDone =
                  !isLast && steps[index + 1].done && step.done;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      _StepDot(done: step.done),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 32,
                          color: nextDone
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: step.done
                                ? AppColors.textPrimary
                                : AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          step.time,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final bool done;
  const _StepDot({required this.done});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done ? AppColors.primary : AppColors.border,
      ),
      alignment: Alignment.center,
      child: done
          ? const Icon(Icons.check, size: 12, color: Colors.white)
          : Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.textMuted,
                shape: BoxShape.circle,
              ),
            ),
    );
  }
}

/// Section listing booking metadata: id, court, date, time, sport, amount.
class _BookingInfoCard extends StatelessWidget {
  final String bookingId;
  final String court;
  final String date;
  final String time;
  final String sport;
  final String amount;

  const _BookingInfoCard({
    super.key,
    required this.bookingId,
    required this.court,
    required this.date,
    required this.time,
    required this.sport,
    required this.amount,
  });

  factory _BookingInfoCard.fromBooking({
    Key? key,
    required String id,
    required Venue venue,
    required String court,
    required String date,
    required String time,
    required String amount,
  }) {
    return _BookingInfoCard(
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
          InfoRow(label: 'Môn thể thao', value: sport),
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

/// Visual placeholder for the QR check-in code.
///
/// Renders a generic QR icon — actual QR generation should be wired
/// later against the booking id via a QR package.
class _QrCodeCard extends StatelessWidget {
  const _QrCodeCard();

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: const [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'QR Check-in',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(height: 16),
          _QrPlaceholder(),
          SizedBox(height: 12),
          Text(
            'Xuất trình mã QR này khi đến sân để check-in',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _QrPlaceholder extends StatelessWidget {
  const _QrPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 2),
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.qr_code,
        color: AppColors.textPrimary,
        size: 100,
      ),
    );
  }
}

/// Bottom action stack for the booking detail page.
///
/// Shows a destructive "Hủy đặt sân" button only when the booking is
/// still upcoming; otherwise shows a generic "rebook" + "contact" pair.
class _BookingActionButtons extends StatelessWidget {
  final String status;
  final VoidCallback? onCancel;
  final VoidCallback? onRebook;
  final VoidCallback? onContact;

  const _BookingActionButtons({
    required this.status,
    this.onCancel,
    this.onRebook,
    this.onContact,
  });

  @override
  Widget build(BuildContext context) {
    final isUpcoming = status == BookingStatus.upcoming;

    return Column(
      children: [
        if (isUpcoming) ...[
          ElevatedButton(
            onPressed: onCancel,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dangerSurface,
              foregroundColor: AppColors.danger,
              elevation: 0,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(
                  color: AppColors.dangerSoft,
                  width: 1.5,
                ),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.close, size: 16),
                SizedBox(width: 8),
                Text(
                  'Hủy đặt sân',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
        _SecondaryButton(
          icon: Icons.refresh,
          label: 'Đặt lại sân này',
          onPressed: onRebook,
        ),
        const SizedBox(height: 10),
        _SecondaryButton(
          icon: Icons.chat_bubble_outline,
          label: 'Liên hệ ban quản lý',
          onPressed: onContact,
        ),
      ],
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const _SecondaryButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        backgroundColor: AppColors.surface,
        minimumSize: const Size(double.infinity, 50),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
