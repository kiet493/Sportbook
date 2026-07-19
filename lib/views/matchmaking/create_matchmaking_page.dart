import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/community_models.dart';
import '../../models/court_booking.dart';
import '../../providers/booking_providers.dart';
import '../../providers/community_providers.dart';
import '../../providers/registration_providers.dart';

class CreateMatchmakingPage extends ConsumerStatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onBookCourt;
  final ValueChanged<MatchmakingRoom> onCreated;

  const CreateMatchmakingPage({
    super.key,
    required this.onBack,
    required this.onBookCourt,
    required this.onCreated,
  });

  @override
  ConsumerState<CreateMatchmakingPage> createState() =>
      _CreateMatchmakingPageState();
}

class _CreateMatchmakingPageState extends ConsumerState<CreateMatchmakingPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedCourtKey;
  String? _selectedBookingId;
  String _level = 'Mọi trình độ';
  int _maxMembers = 4;
  String? _error;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final user = ref.read(sessionProvider)?.user;
    if (user == null) return;

    final allBookings =
        ref.read(userBookingsProvider(user.id)).valueOrNull ??
        const <CourtBooking>[];
    final eligibleBookings = _eligibleBookings(allBookings);
    final booking = _resolveSelectedBooking(eligibleBookings);
    if (booking == null) {
      setState(() {
        _error = 'Vui lòng chọn sân và khung giờ từ lịch đã đặt.';
      });
      return;
    }

    final playAt = booking.scheduledStart;
    if (playAt == null) {
      setState(() => _error = 'Không xác định được giờ bắt đầu booking.');
      return;
    }

    final room = MatchmakingRoom(
      id: '',
      bookingId: booking.id,
      venueId: booking.venueId,
      courtId: booking.courtId,
      courtName: _courtName(booking),
      title: _titleController.text,
      sport: 'Cầu lông',
      venueName: _venueName(booking),
      playAt: playAt,
      skillLevel: _level,
      maxMembers: _maxMembers,
      memberCount: 1,
      createdBy: user.id,
      creatorName: user.fullName,
      description: _descriptionController.text.trim(),
      status: 'open',
    );
    final error = await ref
        .read(createMatchmakingProvider.notifier)
        .create(room);
    if (!mounted) return;
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    final saved = ref.read(createMatchmakingProvider).valueOrNull;
    if (saved != null) widget.onCreated(saved);
  }

  CourtBooking? _resolveSelectedBooking(List<CourtBooking> bookings) {
    final grouped = _groupBookingsByCourt(bookings);
    final courtKey =
        _selectedCourtKey ?? (grouped.length == 1 ? grouped.keys.first : null);
    if (courtKey == null) return null;
    final courtBookings = grouped[courtKey] ?? const <CourtBooking>[];
    if (_selectedBookingId != null) {
      for (final booking in courtBookings) {
        if (booking.id == _selectedBookingId) return booking;
      }
    }
    return courtBookings.length == 1 ? courtBookings.first : null;
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(sessionProvider)?.user;
    final bookingsAsync = user == null
        ? const AsyncData<List<CourtBooking>>([])
        : ref.watch(userBookingsProvider(user.id));
    final eligibleBookings = _eligibleBookings(
      bookingsAsync.valueOrNull ?? const [],
    );
    final groupedBookings = _groupBookingsByCourt(eligibleBookings);
    final effectiveCourtKey = groupedBookings.containsKey(_selectedCourtKey)
        ? _selectedCourtKey
        : (groupedBookings.length == 1 ? groupedBookings.keys.first : null);
    final timeBookings = effectiveCourtKey == null
        ? const <CourtBooking>[]
        : groupedBookings[effectiveCourtKey] ?? const <CourtBooking>[];
    final effectiveBookingId =
        timeBookings.any((booking) => booking.id == _selectedBookingId)
        ? _selectedBookingId
        : (timeBookings.length == 1 ? timeBookings.first.id : null);
    final loading = ref.watch(createMatchmakingProvider).isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          onPressed: widget.onBack,
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        title: const Text('Tạo phòng ghép'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _Input(controller: _titleController, label: 'Tên phòng'),
          const SizedBox(height: 14),
          if (bookingsAsync.isLoading)
            const _BookingMessage(
              icon: Icons.sync,
              message: 'Đang tải lịch đặt sân của bạn...',
              loading: true,
            )
          else if (bookingsAsync.hasError)
            _BookingMessage(
              icon: Icons.cloud_off_outlined,
              message: 'Không thể tải lịch đặt sân. Vui lòng thử lại.',
              actionLabel: 'Tải lại',
              onAction: user == null
                  ? null
                  : () => ref.invalidate(userBookingsProvider(user.id)),
            )
          else if (eligibleBookings.isEmpty)
            _BookingMessage(
              icon: Icons.event_busy_outlined,
              message:
                  'Bạn chưa có booking sắp tới. Hãy đặt sân trước khi tạo phòng ghép.',
              actionLabel: 'Đi đặt sân',
              onAction: widget.onBookCourt,
            )
          else ...[
            DropdownButtonFormField<String>(
              key: ValueKey('court-$effectiveCourtKey'),
              initialValue: effectiveCourtKey,
              isExpanded: true,
              decoration: _decoration('Sân đã đặt'),
              hint: const Text('Chọn sân'),
              items: [
                for (final entry in groupedBookings.entries)
                  DropdownMenuItem(
                    value: entry.key,
                    child: Text(
                      _courtBookingLabel(entry.value.first),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCourtKey = value;
                  _selectedBookingId = null;
                  _error = null;
                });
              },
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              key: ValueKey('booking-$effectiveCourtKey-$effectiveBookingId'),
              initialValue: effectiveBookingId,
              isExpanded: true,
              decoration: _decoration('Khung giờ đã đặt'),
              hint: Text(
                effectiveCourtKey == null
                    ? 'Chọn sân trước'
                    : 'Chọn ngày và giờ chơi',
              ),
              items: [
                for (final booking in timeBookings)
                  DropdownMenuItem(
                    value: booking.id,
                    child: Text(
                      _bookingTimeLabel(booking),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: effectiveCourtKey == null
                  ? null
                  : (value) {
                      setState(() {
                        _selectedBookingId = value;
                        _error = null;
                      });
                    },
            ),
          ],
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: _level,
            decoration: _decoration('Trình độ'),
            items: const [
              DropdownMenuItem(
                value: 'Mọi trình độ',
                child: Text('Mọi trình độ'),
              ),
              DropdownMenuItem(value: 'Mới chơi', child: Text('Mới chơi')),
              DropdownMenuItem(value: 'Trung bình', child: Text('Trung bình')),
              DropdownMenuItem(value: 'Nâng cao', child: Text('Nâng cao')),
            ],
            onChanged: (value) => setState(() => _level = value ?? _level),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<int>(
            initialValue: _maxMembers,
            decoration: _decoration('Số người tối đa'),
            items: [
              for (final value in [2, 4, 6, 8, 10, 12])
                DropdownMenuItem(value: value, child: Text('$value người')),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _maxMembers = value);
            },
          ),
          const SizedBox(height: 14),
          _Input(
            controller: _descriptionController,
            label: 'Mô tả / ghi chú',
            maxLines: 4,
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Color(0xFFDC2626))),
          ],
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: loading || eligibleBookings.isEmpty ? null : _create,
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 54),
            ),
            icon: loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.group_add_outlined),
            label: const Text('Tạo phòng'),
          ),
        ],
      ),
    );
  }
}

List<CourtBooking> _eligibleBookings(List<CourtBooking> bookings) {
  final now = DateTime.now();
  final result = bookings.where((booking) {
    final start = booking.scheduledStart;
    return booking.id.isNotEmpty &&
        booking.venueId.isNotEmpty &&
        booking.venueName.isNotEmpty &&
        booking.courtId.isNotEmpty &&
        booking.courtName.isNotEmpty &&
        booking.status == CourtSlotStatus.booked &&
        start != null &&
        start.isAfter(now);
  }).toList();
  result.sort((a, b) {
    final aStart = a.scheduledStart ?? DateTime.fromMillisecondsSinceEpoch(0);
    final bStart = b.scheduledStart ?? DateTime.fromMillisecondsSinceEpoch(0);
    return aStart.compareTo(bStart);
  });
  return result;
}

Map<String, List<CourtBooking>> _groupBookingsByCourt(
  List<CourtBooking> bookings,
) {
  final grouped = <String, List<CourtBooking>>{};
  for (final booking in bookings) {
    grouped.putIfAbsent(_courtKey(booking), () => []).add(booking);
  }
  return grouped;
}

String _courtKey(CourtBooking booking) =>
    '${booking.venueId}::${booking.courtId}';

String _venueName(CourtBooking booking) {
  final name = booking.venueName.trim();
  return name.isEmpty ? 'Cụm sân ${booking.venueId}' : name;
}

String _courtName(CourtBooking booking) {
  final name = booking.courtName.trim();
  return name.isEmpty ? 'Sân ${booking.courtId}' : name;
}

String _courtBookingLabel(CourtBooking booking) =>
    '${_venueName(booking)} · ${_courtName(booking)}';

String _bookingTimeLabel(CourtBooking booking) {
  final start = booking.scheduledStart;
  if (start == null) return booking.timeRange;
  final day = start.day.toString().padLeft(2, '0');
  final month = start.month.toString().padLeft(2, '0');
  return '$day/$month/${start.year} · ${booking.timeRange}';
}

class _BookingMessage extends StatelessWidget {
  final IconData icon;
  final String message;
  final bool loading;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _BookingMessage({
    required this.icon,
    required this.message,
    this.loading = false,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFCBD5E1)),
    ),
    child: Column(
      children: [
        if (loading)
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else
          Icon(icon, color: const Color(0xFF64748B)),
        const SizedBox(height: 10),
        Text(message, textAlign: TextAlign.center),
        if (actionLabel != null && onAction != null) ...[
          const SizedBox(height: 10),
          OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ],
    ),
  );
}

class _Input extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int maxLines;

  const _Input({
    required this.controller,
    required this.label,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    maxLines: maxLines,
    decoration: _decoration(label),
  );
}

InputDecoration _decoration(String label) => InputDecoration(
  labelText: label,
  filled: true,
  fillColor: Colors.white,
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
);
