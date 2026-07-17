import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/bottom_nav.dart';
import '../../models/venue.dart';
import '../../providers/booking_providers.dart';
import 'widgets/booking_history_card.dart';
import 'widgets/booking_history_view.dart';

/// Booking history list with search + status tabs.
///
/// All sub-widgets live in `widgets/booking_history_view.dart` and
/// `widgets/booking_history_card.dart`. This state class only handles
/// the filter logic + scroll list.
class BookingHistoryPage extends ConsumerStatefulWidget {
  final VoidCallback onBack;
  final ValueChanged<BookingInfo> onViewDetail;
  final ValueChanged<Venue> onRebook;
  final ValueChanged<String> onNav;
  final String activeNav;

  const BookingHistoryPage({
    super.key,
    required this.onBack,
    required this.onViewDetail,
    required this.onRebook,
    required this.onNav,
    required this.activeNav,
  });

  @override
  ConsumerState<BookingHistoryPage> createState() =>
      _BookingHistoryPageState();
}

class _BookingHistoryPageState extends ConsumerState<BookingHistoryPage> {
  String _activeTab = "upcoming";
  String _searchQuery = "";
  final _searchController = TextEditingController();

  List<BookingInfo> _filteredBookings(List<BookingInfo> bookings) {
    return bookings.where((booking) {
      final matchesTab = booking.status == _activeTab;
      final matchesSearch =
          _searchQuery.isEmpty ||
          booking.venue.name
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
      return matchesTab && matchesSearch;
    }).toList();
  }

  int _countByStatus(List<BookingInfo> bookings, String status) {
    return bookings.where((booking) => booking.status == status).length;
  }

  void _updateSearchQuery(String value) {
    setState(() => _searchQuery = value);
  }

  void _clearSearchQuery() {
    _searchController.clear();
    setState(() => _searchQuery = "");
  }

  void _updateActiveTab(String tab) {
    setState(() => _activeTab = tab);
  }

  Future<void> _cancelBooking(BookingInfo booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy lịch đặt sân?'),
        content: Text(
          'Bạn có chắc muốn hủy ${booking.court} vào ${booking.time}, ${booking.date}?',
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

    final error = await ref
        .read(bookingCancelProvider.notifier)
        .cancel(booking.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'Đã hủy lịch đặt sân.'),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(currentUserBookingInfosProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: bookingsAsync.when(
                data: (bookings) {
                  final filteredBookings = _filteredBookings(bookings);
                  return Column(
                    children: [
                      BookingHistoryHeader(
                        searchController: _searchController,
                        searchQuery: _searchQuery,
                        onSearchChanged: _updateSearchQuery,
                        onClearSearch: _clearSearchQuery,
                        activeTab: _activeTab,
                        onTabChanged: _updateActiveTab,
                        countByStatus: (status) =>
                            _countByStatus(bookings, status),
                      ),
                      Expanded(
                        child: filteredBookings.isEmpty
                            ? const BookingHistoryEmptyState()
                            : ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.only(
                                  left: 16,
                                  right: 16,
                                  bottom: 90,
                                  top: 8,
                                ),
                                itemCount: filteredBookings.length,
                                itemBuilder: (context, index) {
                                  final booking = filteredBookings[index];
                                  return BookingHistoryCard(
                                    booking: booking,
                                    onViewDetail: widget.onViewDetail,
                                    onCancel: () => _cancelBooking(booking),
                                    onRebook: () =>
                                        widget.onRebook(booking.venue),
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, _) => _BookingHistoryError(
                  onRetry: () =>
                      ref.invalidate(currentUserBookingInfosProvider),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        activeScreen: widget.activeNav,
        onNav: widget.onNav,
      ),
    );
  }
}

class _BookingHistoryError extends StatelessWidget {
  final VoidCallback onRetry;

  const _BookingHistoryError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 42, color: Color(0xFF94A3B8)),
            const SizedBox(height: 12),
            const Text('Không tải được lịch sử đặt sân.'),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRetry, child: const Text('Thử lại')),
          ],
        ),
      ),
    );
  }
}
