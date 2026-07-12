import 'package:flutter/material.dart';

import '../../../models/court_booking.dart';

class BookingScheduleBoard extends StatelessWidget {
  final List<SportCourt> courts;
  final List<CourtBooking> bookings;
  final int durationMinutes;
  final CourtSlotSelection? selection;
  final ValueChanged<CourtSlotSelection> onSelected;

  const BookingScheduleBoard({
    super.key,
    required this.courts,
    required this.bookings,
    required this.durationMinutes,
    required this.selection,
    required this.onSelected,
  });

  static const int startMinute = 6 * 60;
  static const int endMinute = 22 * 60 + 30;
  static const int stepMinute = 30;
  static const double labelWidth = 72;
  static const double cellWidth = 58;
  static const double rowHeight = 48;

  List<int> get _slots => [
    for (var minute = startMinute; minute < endMinute; minute += stepMinute)
      minute,
  ];

  @override
  Widget build(BuildContext context) {
    final slots = _slots;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEAFDF4),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFB7E4D0)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _LegendBar(),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TimeHeader(slots: slots),
                ...courts.map(
                  (court) => _CourtRow(
                    court: court,
                    slots: slots,
                    bookings: bookings,
                    durationMinutes: durationMinutes,
                    selection: selection,
                    onSelected: onSelected,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF047857),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: const Wrap(
        spacing: 14,
        runSpacing: 8,
        children: [
          _LegendItem(color: Colors.white, label: 'Trong'),
          _LegendItem(color: Color(0xFFEF4444), label: 'Da dat'),
          _LegendItem(color: Color(0xFF9CA3AF), label: 'Khoa'),
          _LegendItem(color: Color(0xFFC084FC), label: 'Su kien'),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _TimeHeader extends StatelessWidget {
  final List<int> slots;

  const _TimeHeader({required this.slots});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: BookingScheduleBoard.labelWidth),
        ...slots.map(
          (minute) => SizedBox(
            width: BookingScheduleBoard.cellWidth,
            height: 34,
            child: Center(
              child: Text(
                formatMinutes(minute),
                style: const TextStyle(
                  color: Color(0xFF065F46),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CourtRow extends StatelessWidget {
  final SportCourt court;
  final List<int> slots;
  final List<CourtBooking> bookings;
  final int durationMinutes;
  final CourtSlotSelection? selection;
  final ValueChanged<CourtSlotSelection> onSelected;

  const _CourtRow({
    required this.court,
    required this.slots,
    required this.bookings,
    required this.durationMinutes,
    required this.selection,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: BookingScheduleBoard.labelWidth,
          height: BookingScheduleBoard.rowHeight,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Color(0xFFD1FAE5),
            border: Border(
              top: BorderSide(color: Color(0xFF9CA3AF), width: 0.7),
              right: BorderSide(color: Color(0xFF9CA3AF), width: 0.7),
            ),
          ),
          child: Text(
            court.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF064E3B),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        ...slots.map(
          (minute) => _SlotCell(
            court: court,
            minute: minute,
            bookings: bookings,
            durationMinutes: durationMinutes,
            selected:
                selection?.court.id == court.id &&
                selection?.startMinutes == minute,
            onSelected: onSelected,
          ),
        ),
      ],
    );
  }
}

class _SlotCell extends StatelessWidget {
  final SportCourt court;
  final int minute;
  final List<CourtBooking> bookings;
  final int durationMinutes;
  final bool selected;
  final ValueChanged<CourtSlotSelection> onSelected;

  const _SlotCell({
    required this.court,
    required this.minute,
    required this.bookings,
    required this.durationMinutes,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final end = minute + BookingScheduleBoard.stepMinute;
    final blocking = bookings.where((booking) {
      if (booking.courtId != court.id) {
        return false;
      }
      if (!CourtSlotStatus.activeStatuses.contains(booking.status)) {
        return false;
      }
      return rangesOverlap(
        minute,
        end,
        booking.startMinutes,
        booking.endMinutes,
      );
    }).firstOrNull;

    final canSelect =
        court.active &&
        blocking == null &&
        minute + durationMinutes <= BookingScheduleBoard.endMinute &&
        !_selectionWouldOverlap();

    final bgColor = !court.active
        ? const Color(0xFF9CA3AF)
        : blocking != null
        ? CourtSlotStatus.color(blocking.status)
        : selected
        ? const Color(0xFFBBF7D0)
        : Colors.white;

    return InkWell(
      onTap: canSelect
          ? () => onSelected(
              CourtSlotSelection(court: court, startMinutes: minute),
            )
          : null,
      child: Container(
        width: BookingScheduleBoard.cellWidth,
        height: BookingScheduleBoard.rowHeight,
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(
            color: selected ? const Color(0xFF111827) : const Color(0xFF9CA3AF),
            width: selected ? 1.8 : 0.55,
          ),
        ),
        child: blocking != null
            ? const SizedBox.shrink()
            : selected
            ? const Icon(Icons.check, color: Color(0xFF047857), size: 18)
            : null,
      ),
    );
  }

  bool _selectionWouldOverlap() {
    final selectedEnd = minute + durationMinutes;
    return bookings.any((booking) {
      if (booking.courtId != court.id) {
        return false;
      }
      if (!CourtSlotStatus.activeStatuses.contains(booking.status)) {
        return false;
      }
      return rangesOverlap(
        minute,
        selectedEnd,
        booking.startMinutes,
        booking.endMinutes,
      );
    });
  }
}
