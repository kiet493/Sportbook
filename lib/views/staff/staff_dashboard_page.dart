import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/currency_formatter.dart';
import '../../models/court_booking.dart';
import '../../models/staff_sale.dart';
import '../../providers/booking_providers.dart';
import '../../providers/registration_providers.dart';
import '../../providers/staff_providers.dart';

class StaffDashboardPage extends ConsumerStatefulWidget {
  final VoidCallback onLogout;

  const StaffDashboardPage({super.key, required this.onLogout});

  @override
  ConsumerState<StaffDashboardPage> createState() => _StaffDashboardPageState();
}

class _StaffDashboardPageState extends ConsumerState<StaffDashboardPage> {
  late DateTime _selectedDate;
  String _selectedCourtId = '';

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(sessionProvider)?.user;
    final venueId = user?.staffVenueId ?? '';
    if (user == null || venueId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Nhân viên cụm sân')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Tài khoản staff chưa được admin gán cụm sân.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final bookingsAsync = ref.watch(staffVenueBookingsProvider(venueId));
    final salesAsync = ref.watch(staffVenueSalesProvider(venueId));
    final courtsAsync = ref.watch(venueCourtsProvider(venueId));
    final courtIds = courtsAsync.valueOrNull?.map((court) => court.id).toSet();
    final effectiveCourtId =
        _selectedCourtId.isEmpty ||
            courtIds == null ||
            courtIds.contains(_selectedCourtId)
        ? _selectedCourtId
        : '';
    final selectedKey = dateKey(_selectedDate);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Quản lý cụm sân'),
            Text(
              user.staffVenueName,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Gửi báo cáo cho admin',
            onPressed: _sendReport,
            icon: const Icon(Icons.add_comment_outlined),
          ),
          IconButton(
            tooltip: 'Đăng xuất',
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(staffVenueBookingsProvider(venueId));
          ref.invalidate(staffVenueSalesProvider(venueId));
          await Future<void>.delayed(const Duration(milliseconds: 250));
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            courtsAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (error, _) =>
                  _ErrorCard(message: 'Không tải được sân: $error'),
              data: (courts) => DropdownButtonFormField<String>(
                key: ValueKey(effectiveCourtId),
                initialValue: effectiveCourtId,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Lọc theo sân',
                  prefixIcon: Icon(Icons.sports_tennis),
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(value: '', child: Text('Tất cả sân')),
                  for (final court in courts)
                    DropdownMenuItem(
                      value: court.id,
                      child: Text(court.name, overflow: TextOverflow.ellipsis),
                    ),
                ],
                onChanged: (value) =>
                    setState(() => _selectedCourtId = value ?? ''),
              ),
            ),
            const SizedBox(height: 12),
            _DateFilter(date: _selectedDate, onTap: _pickDate),
            const SizedBox(height: 14),
            bookingsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) =>
                  _ErrorCard(message: 'Không tải được booking: $error'),
              data: (allBookings) => salesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) =>
                    _ErrorCard(message: 'Không tải được doanh thu: $error'),
                data: (allSales) {
                  final bookings = allBookings
                      .where(
                        (booking) =>
                            booking.dateKey == selectedKey &&
                            (effectiveCourtId.isEmpty ||
                                booking.courtId == effectiveCourtId),
                      )
                      .toList();
                  final bookingIds = bookings
                      .map((booking) => booking.id)
                      .toSet();
                  final sales = {
                    for (final sale in allSales)
                      if (sale.dateKey == selectedKey &&
                          bookingIds.contains(sale.bookingId))
                        sale.bookingId: sale,
                  };
                  final bookingRevenue = bookings.fold<int>(
                    0,
                    (total, booking) =>
                        total +
                        (booking.paymentStatus.isEmpty ||
                                booking.paymentStatus == 'paid'
                            ? booking.totalPrice
                            : 0),
                  );
                  final waterRevenue = sales.values.fold<int>(
                    0,
                    (total, sale) => total + sale.waterRevenue,
                  );
                  final racketRevenue = sales.values.fold<int>(
                    0,
                    (total, sale) => total + sale.racketRevenue,
                  );
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _RevenueSummary(
                        bookingCount: bookings.length,
                        bookingRevenue: bookingRevenue,
                        waterRevenue: waterRevenue,
                        racketRevenue: racketRevenue,
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Lịch sử booking trong ngày',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (bookings.isEmpty)
                        const _EmptyCard()
                      else
                        for (final booking in bookings) ...[
                          _BookingRevenueCard(
                            booking: booking,
                            sale: sales[booking.id],
                            onEdit: () => _editSale(booking, sales[booking.id]),
                          ),
                          const SizedBox(height: 10),
                        ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _sendReport() async {
    final title = TextEditingController();
    final content = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gửi báo cáo cho admin'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: title,
              decoration: const InputDecoration(labelText: 'Tiêu đề'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: content,
              minLines: 4,
              maxLines: 7,
              decoration: const InputDecoration(labelText: 'Nội dung báo cáo'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Gửi báo cáo'),
          ),
        ],
      ),
    );
    final reportTitle = title.text;
    final reportContent = content.text;
    title.dispose();
    content.dispose();
    if (confirmed != true || !mounted) return;
    final error = await ref
        .read(staffSaleActionProvider.notifier)
        .sendReport(title: reportTitle, content: reportContent);
    if (mounted) _message(error ?? 'Đã gửi báo cáo cho admin.');
  }

  Future<void> _editSale(CourtBooking booking, StaffSale? sale) async {
    final water = TextEditingController(text: '${sale?.waterQuantity ?? 0}');
    final racket = TextEditingController(text: '${sale?.racketQuantity ?? 0}');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${booking.courtName} • ${booking.timeRange}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: water,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Số chai nước đã bán',
                helperText: '30.000đ/chai',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: racket,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Số vợt đã cho thuê',
                helperText: '100.000đ/cây',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      water.dispose();
      racket.dispose();
      return;
    }
    final waterQuantity = int.tryParse(water.text.trim());
    final racketQuantity = int.tryParse(racket.text.trim());
    water.dispose();
    racket.dispose();
    if (waterQuantity == null ||
        racketQuantity == null ||
        waterQuantity < 0 ||
        racketQuantity < 0) {
      _message('Số lượng phải là số nguyên không âm.');
      return;
    }
    final error = await ref
        .read(staffSaleActionProvider.notifier)
        .save(
          bookingId: booking.id,
          venueId: booking.venueId,
          dateKey: booking.dateKey,
          waterQuantity: waterQuantity,
          racketQuantity: racketQuantity,
        );
    if (mounted) _message(error ?? 'Đã cập nhật doanh thu phụ trợ.');
  }

  Future<void> _logout() async {
    await ref.read(loginProvider.notifier).logout();
    if (mounted) widget.onLogout();
  }

  void _message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}

class _DateFilter extends StatelessWidget {
  final DateTime date;
  final VoidCallback onTap;

  const _DateFilter({required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: const CircleAvatar(child: Icon(Icons.calendar_month)),
      title: const Text('Lọc theo ngày'),
      subtitle: Text(_displayDate(date)),
      trailing: const Icon(Icons.expand_more),
      onTap: onTap,
    ),
  );
}

class _RevenueSummary extends StatelessWidget {
  final int bookingCount;
  final int bookingRevenue;
  final int waterRevenue;
  final int racketRevenue;

  const _RevenueSummary({
    required this.bookingCount,
    required this.bookingRevenue,
    required this.waterRevenue,
    required this.racketRevenue,
  });

  @override
  Widget build(BuildContext context) {
    final total = bookingRevenue + waterRevenue + racketRevenue;
    return Card(
      color: const Color(0xFFECFDF5),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Doanh thu trong ngày',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            _line('Booking ($bookingCount)', bookingRevenue),
            _line('Nước đã bán', waterRevenue),
            _line('Vợt cho thuê', racketRevenue),
            const Divider(),
            _line('Tổng doanh thu', total, bold: true),
          ],
        ),
      ),
    );
  }

  Widget _line(String label, int amount, {bool bold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(child: Text(label)),
        Text(
          '${formatVnd(amount)}đ',
          style: TextStyle(fontWeight: bold ? FontWeight.w900 : null),
        ),
      ],
    ),
  );
}

class _BookingRevenueCard extends StatelessWidget {
  final CourtBooking booking;
  final StaffSale? sale;
  final VoidCallback onEdit;

  const _BookingRevenueCard({
    required this.booking,
    required this.sale,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${booking.courtName} • ${booking.timeRange}',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              Text('${formatVnd(booking.totalPrice)}đ'),
            ],
          ),
          const SizedBox(height: 6),
          Text('${booking.userName} • ${booking.userPhone}'),
          const SizedBox(height: 8),
          Text(
            'Nước: ${sale?.waterQuantity ?? 0} • Vợt: ${sale?.racketQuantity ?? 0} • '
            'Phụ thu: ${formatVnd(sale?.totalRevenue ?? 0)}đ',
            style: const TextStyle(color: Color(0xFF475569)),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Nhập nước và vợt'),
            ),
          ),
        ],
      ),
    ),
  );
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard();
  @override
  Widget build(BuildContext context) => const Card(
    child: Padding(
      padding: EdgeInsets.all(28),
      child: Text(
        'Không có booking trong ngày này.',
        textAlign: TextAlign.center,
      ),
    ),
  );
}

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});
  @override
  Widget build(BuildContext context) => Card(
    color: const Color(0xFFFEF2F2),
    child: Padding(padding: const EdgeInsets.all(16), child: Text(message)),
  );
}

String _displayDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
