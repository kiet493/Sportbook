import 'package:flutter/material.dart';

import '../../models/venue.dart';
import '../../core/widgets/bottom_nav.dart';
import 'widgets/booking_history_card.dart';
import 'widgets/booking_history_empty_state.dart';
import 'widgets/booking_history_header.dart';

class BookingHistoryPage extends StatefulWidget {
  final VoidCallback onBack;
  final ValueChanged<BookingInfo> onViewDetail;
  final ValueChanged<String> onNav;
  final String activeNav;

  const BookingHistoryPage({
    super.key,
    required this.onBack,
    required this.onViewDetail,
    required this.onNav,
    required this.activeNav,
  });

  @override
  State<BookingHistoryPage> createState() => _BookingHistoryPageState();
}

class _BookingHistoryPageState extends State<BookingHistoryPage> {
  String _activeTab = "upcoming";
  String _searchQuery = "";
  final _searchController = TextEditingController();

  List<BookingInfo> get _filteredBookings {
    return MOCK_BOOKINGS.where((booking) {
      final matchesTab = booking.status == _activeTab;
      final matchesSearch =
          _searchQuery.isEmpty ||
          booking.venue.name.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesTab && matchesSearch;
    }).toList();
  }

  int _countByStatus(String status) {
    return MOCK_BOOKINGS.where((booking) => booking.status == status).length;
  }

  void _updateSearchQuery(String value) {
    setState(() {
      _searchQuery = value;
    });
  }

  void _clearSearchQuery() {
    _searchController.clear();
    setState(() {
      _searchQuery = "";
    });
  }

  void _updateActiveTab(String tab) {
    setState(() {
      _activeTab = tab;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredBookings = _filteredBookings;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            BookingHistoryHeader(
              searchController: _searchController,
              searchQuery: _searchQuery,
              onSearchChanged: _updateSearchQuery,
              onClearSearch: _clearSearchQuery,
              activeTab: _activeTab,
              onTabChanged: _updateActiveTab,
              countByStatus: _countByStatus,
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
                        return BookingHistoryCard(
                          booking: filteredBookings[index],
                          onViewDetail: widget.onViewDetail,
                        );
                      },
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