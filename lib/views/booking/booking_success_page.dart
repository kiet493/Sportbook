import 'package:flutter/material.dart';

import '../../core/utils/currency_formatter.dart';
import '../../models/court_booking.dart';
import '../../models/venue.dart';
import 'widgets/success_bottom_actions.dart';
import 'widgets/success_booking_card.dart';
import 'widgets/success_confetti_background.dart';
import 'widgets/success_hero_check.dart';

/// Post-booking confirmation page. Composes the confetti background,
/// the bouncing success check, the booking summary card, and the
/// sticky bottom actions.
class BookingSuccessPage extends StatefulWidget {
  final Venue venue;
  final CourtBooking booking;
  final VoidCallback onHome;
  final VoidCallback onViewBooking;

  const BookingSuccessPage({
    super.key,
    required this.venue,
    required this.booking,
    required this.onHome,
    required this.onViewBooking,
  });

  @override
  State<BookingSuccessPage> createState() => _BookingSuccessPageState();
}

class _BookingSuccessPageState extends State<BookingSuccessPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _confettiController;
  late final List<ConfettiDot> _dots;

  @override
  void initState() {
    super.initState();
    _dots = buildConfettiDots();
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _confettiController.forward();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SuccessConfettiBackground(
            controller: _confettiController,
            dots: _dots,
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 48),
                        const SuccessHeroCheck(),
                        const SizedBox(height: 24),
                        const Text(
                          "Đặt sân thành công!",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Chúc bạn có một trận đấu tuyệt vời. Hẹn gặp trên sân!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 28),
                        SuccessBookingCard(
                          bookingId: widget.booking.id,
                          venue: widget.venue,
                          court: widget.booking.courtName,
                          date: _formatDate(widget.booking.dateKey),
                          timeRange: widget.booking.timeRange,
                          totalPrice:
                              '${formatVnd(widget.booking.totalPrice)}đ',
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                SuccessBottomActions(
                  onViewBooking: widget.onViewBooking,
                  onHome: widget.onHome,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String rawDate) {
    final date = DateTime.tryParse(rawDate);
    if (date == null) return rawDate;
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}
