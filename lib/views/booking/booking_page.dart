import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/back_chevron_button.dart';
import '../../models/court_booking.dart';
import '../../models/venue.dart';
import '../../providers/booking_providers.dart';
import '../../providers/registration_providers.dart';
import 'widgets/booking_bottom_bar.dart';
import 'widgets/booking_notes_box.dart';
import 'widgets/booking_price_breakdown.dart';
import 'widgets/booking_schedule_board.dart';
import 'widgets/booking_summary_card.dart';
import 'widgets/booking_terms_checkbox.dart';

class BookingPage extends ConsumerStatefulWidget {
  final Venue venue;
  final VoidCallback onBack;
  final ValueChanged<List<CourtBooking>> onConfirm;

  const BookingPage({
    super.key,
    required this.venue,
    required this.onBack,
    required this.onConfirm,
  });

  @override
  ConsumerState<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends ConsumerState<BookingPage> {
  late DateTime _selectedDate;
  CourtSlotSelection? _selectedSlot;
  final Map<String, CourtSlotSelection> _selectedSlots = {};
  bool _agreed = false;
  bool _isLoading = false;
  Timer? _clockTimer;

  final _notesController = TextEditingController();

  List<DateTime> get _dates {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return [for (var i = 0; i < 7; i++) today.add(Duration(days: i))];
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _clockTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    _clockTimer?.cancel();
    super.dispose();
  }

  int get _hourlyPrice =>
      _selectedSlot?.court.pricePerHour ?? widget.venue.priceNum;
  int get _finalTotal => _selectedSlots.values.fold<int>(
    0,
    (total, slot) =>
        total +
        ((slot.court.pricePerHour > 0
                    ? slot.court.pricePerHour
                    : widget.venue.priceNum) /
                2)
            .round(),
  );
  int get _durationMinutes => BookingScheduleBoard.stepMinute;
  String get _selectedDateKey => dateKey(_selectedDate);

  int get _minimumStartMinutes {
    final now = DateTime.now();
    if (dateKey(now) != _selectedDateKey) return 0;
    final current = now.hour * 60 + now.minute;
    return ((current ~/ 30) + 1) * 30;
  }

  Map<String, Set<int>> _availabilityByCourt(List<CourtSchedule> schedules) {
    final result = <String, Set<int>>{};
    for (final schedule in schedules) {
      result
          .putIfAbsent(schedule.fieldId, () => <int>{})
          .addAll(schedule.availableStartMinutes);
    }
    return result;
  }

  Set<int> get _regularOpeningSlots => {
    for (
      var minute = BookingScheduleBoard.startMinute;
      minute < BookingScheduleBoard.endMinute;
      minute += BookingScheduleBoard.stepMinute
    )
      minute,
  };

  bool _isSelectionValid(
    CourtSlotSelection? selection,
    Map<String, Set<int>> availability,
    List<CourtBooking> bookings,
  ) {
    if (selection == null || !selection.court.active) return false;
    final slots = availability[selection.court.id] ?? _regularOpeningSlots;
    if (selection.startMinutes < _minimumStartMinutes) {
      return false;
    }
    final end = selection.startMinutes + _durationMinutes;
    if (end > BookingScheduleBoard.endMinute) return false;
    for (
      var minute = selection.startMinutes;
      minute < end;
      minute += BookingScheduleBoard.stepMinute
    ) {
      if (!slots.contains(minute)) return false;
      if (bookings.any(
        (booking) =>
            booking.courtId == selection.court.id &&
            CourtSlotStatus.activeStatuses.contains(booking.status) &&
            rangesOverlap(
              minute,
              minute + BookingScheduleBoard.stepMinute,
              booking.startMinutes,
              booking.endMinutes,
            ),
      )) {
        return false;
      }
    }
    return true;
  }

  Future<void> _confirmBooking() async {
    if (!_agreed || _selectedSlots.isEmpty) return;

    final schedules = ref
        .read(venueSchedulesProvider(_selectedDateKey))
        .valueOrNull;
    if (schedules == null ||
        !_selectedSlots.values.every(
          (selection) => _isSelectionValid(
            selection,
            _availabilityByCourt(schedules),
            ref
                    .read(
                      venueBookingsProvider(
                        BookingDateQuery(
                          venueId: widget.venue.firestoreId,
                          dateKey: _selectedDateKey,
                        ),
                      ),
                    )
                    .valueOrNull ??
                const [],
          ),
        )) {
      _showMessage('Khung giờ đã chọn không còn hợp lệ. Vui lòng chọn lại.');
      return;
    }

    final session = ref.read(sessionProvider);
    if (session == null) {
      _showMessage('Vui long dang nhap de dat san.');
      return;
    }

    setState(() => _isLoading = true);
    final managedVenue = ManagedVenue.fromLegacy(widget.venue);
    final bookings = _selectedSlots.values
        .map(
          (selected) => CourtBooking(
            id: '',
            venueId: managedVenue.id,
            venueName: managedVenue.name,
            courtId: selected.court.id,
            courtName: selected.court.name,
            userId: session.user.id,
            userName: session.user.fullName,
            userPhone: session.user.phone,
            dateKey: _selectedDateKey,
            startMinutes: selected.startMinutes,
            endMinutes: selected.startMinutes + _durationMinutes,
            totalPrice:
                ((selected.court.pricePerHour > 0
                            ? selected.court.pricePerHour
                            : widget.venue.priceNum) /
                        2)
                    .round(),
            participants: 2,
            status: CourtSlotStatus.booked,
            paymentMethod: 'cash',
            notes: _notesController.text.trim(),
            createdAt: DateTime.now(),
          ),
        )
        .toList();

    String? error;
    final savedBookings = <CourtBooking>[];
    for (final booking in bookings) {
      error = await ref.read(bookingSubmitProvider.notifier).submit(booking);
      if (error != null) break;
      final saved = ref.read(bookingSubmitProvider).valueOrNull;
      if (saved != null) savedBookings.add(saved);
    }
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      _showMessage(error);
      return;
    }

    if (savedBookings.isNotEmpty) {
      widget.onConfirm(List<CourtBooking>.unmodifiable(savedBookings));
    }
  }

  @override
  Widget build(BuildContext context) {
    final venueId = widget.venue.firestoreId;
    final courtsAsync = ref.watch(venueCourtsProvider(venueId));
    final schedulesAsync = ref.watch(venueSchedulesProvider(_selectedDateKey));
    final bookingsAsync = ref.watch(
      venueBookingsProvider(
        BookingDateQuery(venueId: venueId, dateKey: _selectedDateKey),
      ),
    );
    final scheduleSlots = _availabilityByCourt(
      schedulesAsync.valueOrNull ?? const <CourtSchedule>[],
    );
    final selectionIsValid =
        _selectedSlots.isNotEmpty &&
        _selectedSlots.values.every(
          (selection) => _isSelectionValid(
            selection,
            scheduleSlots,
            bookingsAsync.valueOrNull ?? const [],
          ),
        );
    final signedIn = ref.watch(sessionProvider) != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: BackChevronButton(onPressed: widget.onBack),
        title: const Text(
          'Xác nhận đặt sân',
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
                  /* Booking controls are intentionally fixed to one 30-minute slot.
                  BookingCountersCard(
                    durationLabel: '30 phút',
                    players: _players,
                    priceLabel: '${formatVnd(_hourlyPrice)}đ/h',
                    maxPlayers: _maxPlayers,
                    onDurationChanged: (value) => setState(() {
                      _duration = value;
                      if (!_isSelectionValid(_selectedSlot, scheduleSlots,
                          bookingsAsync.valueOrNull ?? const [])) {
                        _selectedSlot = null;
                      }
                    }),
                    onPlayersChanged: (value) =>
                        setState(() => _players = value),
                  ),
                  const SizedBox(height: 16), */
                  _DateStrip(
                    dates: _dates,
                    selected: _selectedDate,
                    onChanged: (date) => setState(() {
                      _selectedDate = date;
                      _selectedSlot = null;
                      _selectedSlots.clear();
                    }),
                  ),
                  const SizedBox(height: 16),
                  courtsAsync.when(
                    data: (courts) => schedulesAsync.when(
                      data: (schedules) => courts.isEmpty
                          ? const _EmptySchedule()
                          : bookingsAsync.when(
                              data: (bookings) => BookingScheduleBoard(
                                courts: courts,
                                bookings: bookings,
                                availableSlotsByCourt: _availabilityByCourt(
                                  schedules,
                                ),
                                durationMinutes: _durationMinutes,
                                minimumStartMinutes: _minimumStartMinutes,
                                selectedSlotKeys: _selectedSlots.keys.toSet(),
                                onSelected: (slot) => setState(() {
                                  final key =
                                      '${slot.court.id}_${slot.startMinutes}';
                                  if (_selectedSlots.containsKey(key)) {
                                    _selectedSlots.remove(key);
                                    _selectedSlot =
                                        _selectedSlots.values.firstOrNull;
                                  } else {
                                    _selectedSlots[key] = slot;
                                    _selectedSlot = slot;
                                  }
                                }),
                                onUnavailableTap: _showMessage,
                              ),
                              error: (error, _) => const _ErrorBox(
                                message: 'Không tải được trạng thái khung giờ.',
                              ),
                              loading: () => const _ScheduleLoading(),
                            ),
                      error: (error, _) => const _ErrorBox(
                        message: 'Không tải được lịch đặt sân.',
                      ),
                      loading: () => const _ScheduleLoading(),
                    ),
                    error: (error, _) => const _ErrorBox(
                      message: 'Không tải được danh sách sân.',
                    ),
                    loading: () => const _ScheduleLoading(),
                  ),
                  if (_selectedSlots.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _SelectedSlotBanner(
                      text:
                          'Đã chọn ${_selectedSlots.length} khung giờ 30 phút',
                    ),
                  ],
                  const SizedBox(height: 16),
                  BookingNotesBox(controller: _notesController),
                  const SizedBox(height: 16),
                  BookingPriceBreakdown(
                    durationLabel: '30 phút',
                    hourlyPrice: _hourlyPrice,
                    finalTotal: _finalTotal,
                  ),
                  const SizedBox(height: 16),
                  BookingTermsCheckbox(
                    agreed: _agreed,
                    onChanged: (value) => setState(() => _agreed = value),
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
              enabled:
                  signedIn &&
                  _agreed &&
                  _selectedSlots.isNotEmpty &&
                  selectionIsValid,
              isLoading: _isLoading,
              onConfirm: _confirmBooking,
            ),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _DateStrip extends StatelessWidget {
  final List<DateTime> dates;
  final DateTime selected;
  final ValueChanged<DateTime> onChanged;

  const _DateStrip({
    required this.dates,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chon ngay dat san',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: dates.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final date = dates[index];
                final active = dateKey(date) == dateKey(selected);
                return ChoiceChip(
                  selected: active,
                  label: Text(_dateLabel(date, index)),
                  onSelected: (_) => onChanged(date),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _dateLabel(DateTime date, int index) {
    if (index == 0) return 'Hôm nay';
    if (index == 1) return 'Ngày mai';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month';
  }
}

class _SelectedSlotBanner extends StatelessWidget {
  final String text;

  const _SelectedSlotBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF86EFAC)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF15803D), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF166534),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleLoading extends StatelessWidget {
  const _ScheduleLoading();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 180,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;

  const _ErrorBox({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(message, style: const TextStyle(color: Color(0xFFB91C1C))),
    );
  }
}

class _EmptySchedule extends StatelessWidget {
  const _EmptySchedule();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          const Icon(Icons.event_busy, color: Color(0xFF64748B)),
          const SizedBox(height: 10),
          const Text(
            'Sân này chưa có lịch trên Firebase. Vui lòng liên hệ quản lý sân.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
