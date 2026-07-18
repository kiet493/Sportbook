import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/court_booking.dart';
import '../../providers/admin_content_providers.dart';
import '../../providers/booking_providers.dart';
import '../../providers/manage_users_providers.dart';

class StatisticsPage extends ConsumerWidget {
  final VoidCallback onBack;
  const StatisticsPage({super.key, required this.onBack});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(allUsersProvider).valueOrNull ?? const [];
    final venues = ref.watch(managedVenuesProvider).valueOrNull ?? const [];
    final courts = ref.watch(allSportCourtsProvider).valueOrNull ?? const [];
    final bookings = ref.watch(adminBookingsProvider).valueOrNull ?? const [];
    final equipment = ref.watch(equipmentProvider).valueOrNull ?? const [];
    final consumables = ref.watch(consumablesProvider).valueOrNull ?? const [];
    final news = ref.watch(newsProvider).valueOrNull ?? const [];
    final policies = ref.watch(policiesProvider).valueOrNull ?? const [];

    final activeBookings = bookings
        .where((booking) => booking.status != CourtSlotStatus.cancelled)
        .toList();
    final cancelled = bookings.length - activeBookings.length;
    final revenue = activeBookings.fold<int>(
      0,
      (total, booking) => total + booking.totalPrice,
    );
    final now = DateTime.now();
    final thisMonth = activeBookings.where((booking) {
      final start = booking.scheduledStart;
      return start != null &&
          start.year == now.year &&
          start.month == now.month;
    }).toList();
    final monthRevenue = thisMonth.fold<int>(
      0,
      (total, booking) => total + booking.totalPrice,
    );
    final maxStatus = bookings.isEmpty ? 1 : bookings.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        title: const Text('Thống kê hệ thống'),
        actions: [
          IconButton(
            tooltip: 'Làm mới',
            onPressed: () {
              ref.invalidate(allUsersProvider);
              ref.invalidate(managedVenuesProvider);
              ref.invalidate(allSportCourtsProvider);
              ref.invalidate(adminBookingsProvider);
              ref.invalidate(equipmentProvider);
              ref.invalidate(consumablesProvider);
              ref.invalidate(newsProvider);
              ref.invalidate(policiesProvider);
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.35,
            children: [
              _Metric(
                icon: Icons.people_outline,
                label: 'Người dùng',
                value: '${users.length}',
              ),
              _Metric(
                icon: Icons.stadium_outlined,
                label: 'Cụm sân',
                value: '${venues.length}',
              ),
              _Metric(
                icon: Icons.sports_tennis,
                label: 'Sân con',
                value: '${courts.length}',
              ),
              _Metric(
                icon: Icons.event_note_outlined,
                label: 'Lượt đặt',
                value: '${bookings.length}',
              ),
            ],
          ),
          const SizedBox(height: 18),
          _RevenueCard(
            totalRevenue: revenue,
            monthRevenue: monthRevenue,
            monthBookings: thisMonth.length,
          ),
          const SizedBox(height: 18),
          const Text(
            'Trạng thái đặt sân',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  _ProgressRow(
                    label: 'Đang hoạt động / hoàn tất',
                    value: activeBookings.length,
                    total: maxStatus,
                    color: const Color(0xFF16A34A),
                  ),
                  const SizedBox(height: 16),
                  _ProgressRow(
                    label: 'Đã hủy',
                    value: cancelled,
                    total: maxStatus,
                    color: const Color(0xFFDC2626),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Nội dung & kho',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.sports_tennis),
                  title: const Text('Thiết bị'),
                  trailing: Text('${equipment.length} loại'),
                ),
                ListTile(
                  leading: const Icon(Icons.inventory_2_outlined),
                  title: const Text('Vật tư tiêu hao'),
                  trailing: Text('${consumables.length} loại'),
                ),
                ListTile(
                  leading: const Icon(Icons.newspaper_outlined),
                  title: const Text('Tin tức'),
                  trailing: Text('${news.length} bài'),
                ),
                ListTile(
                  leading: const Icon(Icons.policy_outlined),
                  title: const Text('Chính sách'),
                  trailing: Text('${policies.length} mục'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _Metric({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF2563EB)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          Text(label, style: const TextStyle(color: Color(0xFF64748B))),
        ],
      ),
    ),
  );
}

class _RevenueCard extends StatelessWidget {
  final int totalRevenue;
  final int monthRevenue;
  final int monthBookings;

  const _RevenueCard({
    required this.totalRevenue,
    required this.monthRevenue,
    required this.monthBookings,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF1D4ED8), Color(0xFF2563EB)],
      ),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Giá trị booking (không gồm payment)',
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 7),
        Text(
          _formatMoney(totalRevenue),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Tháng này: ${_formatMoney(monthRevenue)} · $monthBookings lượt',
          style: const TextStyle(color: Colors.white),
        ),
      ],
    ),
  );
}

class _ProgressRow extends StatelessWidget {
  final String label;
  final int value;
  final int total;
  final Color color;

  const _ProgressRow({
    required this.label,
    required this.value,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(
        children: [
          Expanded(child: Text(label)),
          Text('$value', style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
      const SizedBox(height: 8),
      LinearProgressIndicator(
        value: value / total,
        minHeight: 8,
        borderRadius: BorderRadius.circular(8),
        color: color,
        backgroundColor: color.withValues(alpha: 0.12),
      ),
    ],
  );
}

String _formatMoney(int value) {
  final digits = value.toString();
  final result = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    result.write(digits[i]);
    final remaining = digits.length - i;
    if (remaining > 1 && remaining % 3 == 1) result.write('.');
  }
  return '$result\u0111';
}
