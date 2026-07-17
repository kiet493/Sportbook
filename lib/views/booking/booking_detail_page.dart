import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/back_chevron_button.dart';
import '../../core/widgets/status_badge.dart';
import '../../models/venue.dart';
import '../../providers/booking_providers.dart';
import 'widgets/booking_detail_action_buttons.dart';
import 'widgets/booking_detail_info_card.dart';
import 'widgets/booking_detail_timeline.dart';
import 'widgets/booking_detail_venue_card.dart';

/// Detail view for a single booking. Composition only — every visual
/// block is delegated to a file-specific widget under `widgets/`.
///
/// `onBack` is optional; when null the page falls back to
/// `Navigator.maybePop`. Cancellation is persisted through Riverpod.
class BookingDetailPage extends ConsumerStatefulWidget {
  final BookingInfo booking;
  final VoidCallback? onBack;
  final VoidCallback? onCancel;
  final VoidCallback? onCancelled;
  final VoidCallback? onRebook;
  final VoidCallback? onContact;

  const BookingDetailPage({
    super.key,
    required this.booking,
    this.onBack,
    this.onCancel,
    this.onCancelled,
    this.onRebook,
    this.onContact,
  });

  @override
  ConsumerState<BookingDetailPage> createState() =>
      _BookingDetailPageState();
}

class _BookingDetailPageState extends ConsumerState<BookingDetailPage> {
  late String _status;
  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();
    _status = widget.booking.status;
  }

  Future<void> _cancelBooking() async {
    if (widget.onCancel != null) {
      widget.onCancel!();
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy lịch đặt sân?'),
        content: Text(
          'Khung giờ ${widget.booking.time}, ${widget.booking.date} sẽ được mở lại cho người khác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Giữ lịch'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hủy lịch'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isCancelling = true);
    final error = await ref
        .read(bookingCancelProvider.notifier)
        .cancel(widget.booking.id);
    if (!mounted) return;
    setState(() {
      _isCancelling = false;
      if (error == null) _status = 'cancelled';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? 'Đã hủy lịch đặt sân.')),
    );
    if (error == null) widget.onCancelled?.call();
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
    final timeline = buildBookingTimeline(status: _status);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0.5,
        leading: BackChevronButton(onPressed: widget.onBack),
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
              child: StatusBadge(status: _status),
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
            BookingDetailVenueCard(venue: booking.venue),
            const SizedBox(height: 16),
            BookingDetailTimeline(steps: timeline),
            const SizedBox(height: 16),
            BookingDetailInfoCard(
              bookingId: booking.id,
              court: booking.court,
              date: booking.date,
              time: booking.time,
              sport:
                  booking.venue.sport.isNotEmpty ? booking.venue.sport.first : '—',
              amount: booking.amount,
            ),
            const SizedBox(height: 24),
            BookingDetailActionButtons(
              status: _status,
              onCancel: _status == 'upcoming' && !_isCancelling
                  ? _cancelBooking
                  : null,
              onRebook: widget.onRebook,
              onContact: widget.onContact,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
