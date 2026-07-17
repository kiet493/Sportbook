import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/back_chevron_button.dart';
import '../../core/widgets/status_badge.dart';
import '../../models/court_booking.dart';
import '../../providers/booking_providers.dart';

class AdminBookingsPage extends ConsumerStatefulWidget {
  final VoidCallback onBack;

  const AdminBookingsPage({super.key, required this.onBack});

  @override
  ConsumerState<AdminBookingsPage> createState() =>
      _AdminBookingsPageState();
}

class _AdminBookingsPageState extends ConsumerState<AdminBookingsPage> {
  final _searchController = TextEditingController();
  String _search = '';
  String _status = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(adminBookingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: BackChevronButton(onPressed: widget.onBack),
        title: const Text(
          'Lịch sử đặt sân',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _Filters(
            controller: _searchController,
            search: _search,
            status: _status,
            onSearchChanged: (value) => setState(() => _search = value),
            onClear: () {
              _searchController.clear();
              setState(() => _search = '');
            },
            onStatusChanged: (value) => setState(() => _status = value),
          ),
          Expanded(
            child: bookingsAsync.when(
              data: (bookings) {
                final filtered = bookings.where(_matchesFilter).toList();
                if (filtered.isEmpty) return const _EmptyBookings();
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(adminBookingsProvider);
                    await Future<void>.delayed(
                      const Duration(milliseconds: 200),
                    );
                  },
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) =>
                        _BookingCard(booking: filtered[index]),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _LoadError(
                message: error.toString(),
                onRetry: () => ref.invalidate(adminBookingsProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _matchesFilter(CourtBooking booking) {
    final displayStatus = bookingDisplayStatus(booking);
    if (_status != 'all' && displayStatus != _status) return false;

    final query = _search.trim().toLowerCase();
    if (query.isEmpty) return true;
    return booking.id.toLowerCase().contains(query) ||
        booking.venueName.toLowerCase().contains(query) ||
        booking.courtName.toLowerCase().contains(query) ||
        booking.userName.toLowerCase().contains(query) ||
        booking.userPhone.toLowerCase().contains(query);
  }
}

class _Filters extends StatelessWidget {
  final TextEditingController controller;
  final String search;
  final String status;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClear;
  final ValueChanged<String> onStatusChanged;

  const _Filters({
    required this.controller,
    required this.search,
    required this.status,
    required this.onSearchChanged,
    required this.onClear,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        children: [
          TextField(
            controller: controller,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Tìm theo khách hàng, sân hoặc mã booking',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: search.isEmpty
                  ? null
                  : IconButton(
                      onPressed: onClear,
                      icon: const Icon(Icons.close),
                    ),
              filled: true,
              fillColor: AppColors.surfaceMuted,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _StatusChip(
                  value: 'all',
                  label: 'Tất cả',
                  selected: status == 'all',
                  onChanged: onStatusChanged,
                ),
                _StatusChip(
                  value: 'upcoming',
                  label: 'Sắp tới',
                  selected: status == 'upcoming',
                  onChanged: onStatusChanged,
                ),
                _StatusChip(
                  value: 'completed',
                  label: 'Hoàn thành',
                  selected: status == 'completed',
                  onChanged: onStatusChanged,
                ),
                _StatusChip(
                  value: 'cancelled',
                  label: 'Đã hủy',
                  selected: status == 'cancelled',
                  onChanged: onStatusChanged,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String value;
  final String label;
  final bool selected;
  final ValueChanged<String> onChanged;

  const _StatusChip({
    required this.value,
    required this.label,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        selected: selected,
        label: Text(label),
        onSelected: (_) => onChanged(value),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final CourtBooking booking;

  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final status = bookingDisplayStatus(booking);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  booking.venueName.isEmpty
                      ? 'Cụm sân ${booking.venueId}'
                      : booking.venueName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              StatusBadge(status: status),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${booking.courtName} • ${_formatDate(booking.dateKey)} • ${booking.timeRange}',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const Divider(height: 24, color: AppColors.border),
          _InfoRow(
            icon: Icons.person_outline,
            label: booking.userName.isEmpty ? booking.userId : booking.userName,
          ),
          const SizedBox(height: 7),
          _InfoRow(
            icon: Icons.phone_outlined,
            label: booking.userPhone.isEmpty ? 'Không có SĐT' : booking.userPhone,
          ),
          const SizedBox(height: 7),
          _InfoRow(
            icon: Icons.groups_outlined,
            label: '${booking.participants} người chơi',
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mã: ${_shortId(booking.id)}',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
              Text(
                '${formatVnd(booking.totalPrice)}đ',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _shortId(String value) {
    if (value.length <= 12) return value;
    return '${value.substring(0, 12)}…';
  }

  String _formatDate(String raw) {
    final date = DateTime.tryParse(raw);
    if (date == null) return raw;
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyBookings extends StatelessWidget {
  const _EmptyBookings();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text('Không có booking phù hợp.'),
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _LoadError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, color: AppColors.textMuted, size: 40),
            const SizedBox(height: 10),
            Text(
              'Không tải được lịch sử: $message',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRetry, child: const Text('Thử lại')),
          ],
        ),
      ),
    );
  }
}
