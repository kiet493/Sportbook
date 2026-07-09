import 'package:flutter/material.dart';

import '../../core/widgets/back_chevron_button.dart';
import '../../models/venue.dart';
import 'widgets/booking_bottom_bar.dart';
import 'widgets/booking_counters_card.dart';
import 'widgets/booking_date_time_selectors.dart';
import 'widgets/booking_notes_box.dart';
import 'widgets/booking_payment_methods.dart';
import 'widgets/booking_price_breakdown.dart';
import 'widgets/booking_summary_card.dart';
import 'widgets/booking_terms_checkbox.dart';
import 'widgets/booking_voucher_box.dart';

/// Booking confirmation page. Composes the booking form out of
/// file-specific widgets; all calculations and controller wiring
/// stay in this state class so each child can stay stateless.
class BookingPage extends StatefulWidget {
  final Venue venue;
  final VoidCallback onBack;
  final VoidCallback onConfirm;

  const BookingPage({
    super.key,
    required this.venue,
    required this.onBack,
    required this.onConfirm,
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  String _selectedDate = "Thứ 7, 12/07";
  String _selectedTime = "19:00";
  int _duration = 1;
  int _players = 10;
  String _payMethod = "momo";
  String _appliedVoucher = "";
  bool _agreed = false;
  bool _isLoading = false;

  final _voucherController = TextEditingController();
  final _notesController = TextEditingController();

  static const _dates = [
    "Thứ 5, 10/07",
    "Thứ 6, 11/07",
    "Thứ 7, 12/07",
    "CN, 13/07",
  ];
  static const _times = ["17:00", "18:00", "19:00", "20:00", "21:00"];

  void _applyVoucher() {
    setState(() {
      _appliedVoucher = _voucherController.text.trim().toUpperCase();
    });
  }

  Future<void> _confirmBooking() async {
    if (!_agreed) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    widget.onConfirm();
  }

  @override
  void dispose() {
    _voucherController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  int get _subtotal => widget.venue.priceNum * _duration;
  int get _serviceFee => (_subtotal * 0.05).round();
  int get _discount =>
      _appliedVoucher == "SPORT10" ? (_subtotal * 0.1).round() : 0;
  int get _finalTotal => _subtotal + _serviceFee - _discount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: BackChevronButton(onPressed: widget.onBack),
        title: const Text(
          "Xác nhận đặt sân",
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 130,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BookingSummaryCard(venue: widget.venue),
                  const SizedBox(height: 16),
                  BookingDateTimeSelectors(
                    dates: _dates,
                    selectedDate: _selectedDate,
                    onDateChanged: (v) => setState(() => _selectedDate = v),
                    times: _times,
                    selectedTime: _selectedTime,
                    onTimeChanged: (v) => setState(() => _selectedTime = v),
                  ),
                  const SizedBox(height: 16),
                  BookingCountersCard(
                    duration: _duration,
                    players: _players,
                    priceLabel: widget.venue.price,
                    onDurationChanged: (v) => setState(() => _duration = v),
                    onPlayersChanged: (v) => setState(() => _players = v),
                  ),
                  const SizedBox(height: 16),
                  BookingVoucherBox(
                    controller: _voucherController,
                    onApply: _applyVoucher,
                    discount: _discount,
                  ),
                  const SizedBox(height: 16),
                  BookingPaymentMethods(
                    methods: PAYMENT_METHODS,
                    selectedId: _payMethod,
                    onChanged: (id) => setState(() => _payMethod = id),
                  ),
                  const SizedBox(height: 16),
                  BookingNotesBox(controller: _notesController),
                  const SizedBox(height: 16),
                  BookingPriceBreakdown(
                    duration: _duration,
                    total: _subtotal,
                    serviceFee: _serviceFee,
                    discount: _discount,
                    finalTotal: _finalTotal,
                  ),
                  const SizedBox(height: 16),
                  BookingTermsCheckbox(
                    agreed: _agreed,
                    onChanged: (v) => setState(() => _agreed = v),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BookingBottomBar(
              finalTotal: _finalTotal,
              enabled: _agreed,
              isLoading: _isLoading,
              onConfirm: _confirmBooking,
            ),
          ),
        ],
      ),
    );
  }
}
