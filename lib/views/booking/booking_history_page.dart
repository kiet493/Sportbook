import 'package:flutter/material.dart';

import '../../core/widgets/bottom_nav.dart';
import '../../core/widgets/status_badge.dart';
import '../../models/venue.dart';

/// Booking history list with search + status tabs.
///
/// All sub-widgets are file-private: each one is only used here, so we
/// keep them inside this file rather than scattering across a `widgets/`
/// folder.
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
            _BookingHistoryHeader(
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
                  ? const _BookingHistoryEmptyState()
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
                        return _BookingHistoryCard(
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

class _BookingHistoryHeader extends StatelessWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final String activeTab;
  final ValueChanged<String> onTabChanged;
  final int Function(String status) countByStatus;

  const _BookingHistoryHeader({
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.activeTab,
    required this.onTabChanged,
    required this.countByStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Lịch sử đặt sân",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          _SearchField(
            controller: searchController,
            searchQuery: searchQuery,
            onChanged: onSearchChanged,
            onClear: onClearSearch,
          ),
          const SizedBox(height: 12),
          _BookingHistoryTabs(
            activeTab: activeTab,
            onChanged: onTabChanged,
            countByStatus: countByStatus,
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String searchQuery;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchField({
    required this.controller,
    required this.searchQuery,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const Icon(Icons.search, color: Color(0xFF94A3B8), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
              decoration: const InputDecoration(
                hintText: "Tìm lịch đặt sân...",
                hintStyle: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 13,
                  fontWeight: FontWeight.normal,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          if (searchQuery.isNotEmpty)
            GestureDetector(
              onTap: onClear,
              child: const Icon(
                Icons.close,
                color: Color(0xFF94A3B8),
                size: 16,
              ),
            ),
        ],
      ),
    );
  }
}

class _BookingHistoryTabs extends StatelessWidget {
  final String activeTab;
  final ValueChanged<String> onChanged;
  final int Function(String status) countByStatus;

  const _BookingHistoryTabs({
    required this.activeTab,
    required this.onChanged,
    required this.countByStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _TabButton(
            status: "upcoming",
            label: "Sắp tới",
            isSelected: activeTab == "upcoming",
            count: countByStatus("upcoming"),
            onTap: onChanged,
          ),
          _TabButton(
            status: "completed",
            label: "Hoàn thành",
            isSelected: activeTab == "completed",
            count: countByStatus("completed"),
            onTap: onChanged,
          ),
          _TabButton(
            status: "cancelled",
            label: "Đã hủy",
            isSelected: activeTab == "cancelled",
            count: countByStatus("cancelled"),
            onTap: onChanged,
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String status;
  final String label;
  final bool isSelected;
  final int count;
  final ValueChanged<String> onTap;

  const _TabButton({
    required this.status,
    required this.label,
    required this.isSelected,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(status),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? const Color(0xFF0F172A)
                      : const Color(0xFF64748B),
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF2563EB)
                        : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "$count",
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _BookingHistoryEmptyState extends StatelessWidget {
  const _BookingHistoryEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.book_outlined,
                color: Color(0xFF94A3B8),
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Không có lịch đặt sân",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Bạn chưa có lịch đặt sân nào trong mục này.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingHistoryCard extends StatelessWidget {
  final BookingInfo booking;
  final ValueChanged<BookingInfo> onViewDetail;

  const _BookingHistoryCard({
    required this.booking,
    required this.onViewDetail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _VenueThumbnail(image: booking.venue.image),
                const SizedBox(width: 12),
                Expanded(child: _CardInfo(booking: booking)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  booking.amount,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2563EB),
                  ),
                ),
                _CardActions(
                  booking: booking,
                  onViewDetail: onViewDetail,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VenueThumbnail extends StatelessWidget {
  final String image;

  const _VenueThumbnail({required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(image: NetworkImage(image), fit: BoxFit.cover),
      ),
    );
  }
}

class _CardInfo extends StatelessWidget {
  final BookingInfo booking;

  const _CardInfo({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                booking.venue.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
            StatusBadge(status: booking.status),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          "${booking.venue.sport[0]} • ${booking.court}",
          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 6),
        _MetaRow(icon: Icons.calendar_today, value: booking.date),
        const SizedBox(height: 2),
        _MetaRow(icon: Icons.access_time, value: booking.time),
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String value;

  const _MetaRow({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 10, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
      ],
    );
  }
}

class _CardActions extends StatelessWidget {
  final BookingInfo booking;
  final ValueChanged<BookingInfo> onViewDetail;

  const _CardActions({
    required this.booking,
    required this.onViewDetail,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (booking.status == "upcoming") ...[
          _PillActionButton(
            label: "Hủy",
            foregroundColor: const Color(0xFFEF4444),
            borderColor: const Color(0xFFFEE2E2),
            backgroundColor: const Color(0xFFFEF2F2),
            onPressed: () {},
          ),
          const SizedBox(width: 6),
        ],
        if (booking.status != "cancelled") ...[
          _PillActionButton(
            label: "Đặt lại",
            foregroundColor: const Color(0xFF2563EB),
            borderColor: const Color(0xFFDBEAFE),
            backgroundColor: const Color(0xFFEFF6FF),
            onPressed: () {},
          ),
          const SizedBox(width: 6),
        ],
        ElevatedButton(
          onPressed: () => onViewDetail(booking),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            minimumSize: const Size(0, 32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            "Chi tiết",
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class _PillActionButton extends StatelessWidget {
  final String label;
  final Color foregroundColor;
  final Color borderColor;
  final Color backgroundColor;
  final VoidCallback onPressed;

  const _PillActionButton({
    required this.label,
    required this.foregroundColor,
    required this.borderColor,
    required this.backgroundColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: foregroundColor,
        side: BorderSide(color: borderColor),
        backgroundColor: backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        minimumSize: const Size(0, 32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
