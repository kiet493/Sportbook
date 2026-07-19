import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/back_chevron_button.dart';
import '../../models/court_booking.dart';
import '../../providers/booking_providers.dart';
import '../../services/Firebase/booking_firestore_service.dart';

/// Admin-only grid for turning individual 30-minute court slots into
/// maintenance time. The customer schedule listens to the same lock documents.
class ManageMaintenancePage extends ConsumerStatefulWidget {
  final VoidCallback onBack;

  const ManageMaintenancePage({super.key, required this.onBack});

  @override
  ConsumerState<ManageMaintenancePage> createState() => _ManageMaintenancePageState();
}

class _ManageMaintenancePageState extends ConsumerState<ManageMaintenancePage> {
  late DateTime _date;
  String? _venueId;
  String? _courtId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _date = DateTime(now.year, now.month, now.day);
  }

  @override
  Widget build(BuildContext context) {
    final venues = ref.watch(managedVenuesProvider).valueOrNull ?? const [];
    if (_venueId != null && !venues.any((venue) => venue.id == _venueId)) _venueId = null;
    final venueId = _venueId ?? (venues.isEmpty ? null : venues.first.id);
    final courts = (ref.watch(allSportCourtsProvider).valueOrNull ?? const [])
        .where((court) => court.venueId == venueId).toList();
    if (_courtId != null && !courts.any((court) => court.id == _courtId)) _courtId = null;
    final courtId = _courtId ?? (courts.isEmpty ? null : courts.first.id);
    final key = dateKey(_date);
    final locks = venueId == null
        ? const <CourtBooking>[]
        : ref.watch(venueBookingsProvider(BookingDateQuery(venueId: venueId, dateKey: key))).valueOrNull ?? const [];

    return Scaffold(
      appBar: AppBar(
        leading: BackChevronButton(onPressed: widget.onBack),
        title: const Text('Quản lý giờ bảo trì'),
      ),
      body: venues.isEmpty ? const Center(child: Text('Chưa có sân để quản lý.')) : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Chạm vào ô trống để khóa bảo trì (màu bạc). Chạm lại ô bạc để mở. Ô đỏ đã có khách đặt và không thể thay đổi.'),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: venueId,
            decoration: const InputDecoration(labelText: 'Cụm sân'),
            items: [for (final venue in venues) DropdownMenuItem(value: venue.id, child: Text(venue.name))],
            onChanged: (value) => setState(() { _venueId = value; _courtId = null; }),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: courtId,
            decoration: const InputDecoration(labelText: 'Sân'),
            items: [for (final court in courts) DropdownMenuItem(value: court.id, child: Text(court.name))],
            onChanged: (value) => setState(() => _courtId = value),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 7,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, index) {
                final date = DateTime.now().add(Duration(days: index));
                final normalized = DateTime(date.year, date.month, date.day);
                return ChoiceChip(
                  selected: dateKey(normalized) == key,
                  label: Text(index == 0 ? 'Hôm nay' : '${normalized.day}/${normalized.month}'),
                  onSelected: (_) => setState(() => _date = normalized),
                );
              },
            ),
          ),
          const SizedBox(height: 18),
          if (courtId != null) Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var minute = 6 * 60; minute < 22 * 60 + 30; minute += 30)
                _slotButton(courtId, venueId!, minute, locks),
            ],
          ),
        ],
      ),
    );
  }

  Widget _slotButton(String courtId, String venueId, int minute, List<CourtBooking> locks) {
    final lock = locks.where((item) => item.courtId == courtId && item.startMinutes == minute).firstOrNull;
    final status = lock?.status;
    final booked = status == CourtSlotStatus.booked || status == CourtSlotStatus.event;
    final maintenance = status == CourtSlotStatus.blocked;
    return SizedBox(
      width: 82,
      height: 44,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: booked ? const Color(0xFFEF4444) : maintenance ? const Color(0xFF9CA3AF) : Colors.white,
          foregroundColor: booked || maintenance ? Colors.white : Colors.black87,
          side: const BorderSide(color: Color(0xFFD1D5DB)),
          padding: EdgeInsets.zero,
        ),
        onPressed: booked || _saving ? null : () => _toggle(venueId, courtId, minute, !maintenance),
        child: Text(formatMinutes(minute), style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  Future<void> _toggle(String venueId, String courtId, int minute, bool maintenance) async {
    setState(() => _saving = true);
    try {
      await ref.read(bookingFirestoreServiceProvider).setMaintenanceSlot(
        venueId: venueId, courtId: courtId, selectedDateKey: dateKey(_date),
        startMinutes: minute, maintenance: maintenance,
      );
    } on SlotAlreadyBookedException {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Khung giờ này đã có khách đặt.')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
