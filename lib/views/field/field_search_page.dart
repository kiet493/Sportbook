import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/venue_filter.dart';
import '../../core/widgets/bottom_nav.dart';
import '../../models/venue.dart';
import '../../providers/booking_providers.dart';
import 'widgets/widgets.dart';

class FieldSearchPage extends ConsumerStatefulWidget {
  final VoidCallback onBack;
  final ValueChanged<Venue> onVenueTap;
  final ValueChanged<String> onNav;
  final String activeNav;
  const FieldSearchPage({super.key, required this.onBack, required this.onVenueTap, required this.onNav, required this.activeNav});
  @override
  ConsumerState<FieldSearchPage> createState() => _FieldSearchPageState();
}

class _FieldSearchPageState extends ConsumerState<FieldSearchPage> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  String _query = '', _sortBy = 'Gần nhất', _selectedSport = 'Tất cả';
  bool _showFilter = false, _onlyAvailable = false;
  int? _maxPrice;
  double? _minRating;
  final _sorts = const ['Gần nhất', 'Đánh giá cao', 'Giá thấp nhất', 'Giá cao nhất', 'Phổ biến nhất'];

  @override
  void dispose() { _searchController.dispose(); _focusNode.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final venuesAsync = ref.watch(publicVenuesProvider);
    final loadedVenues = venuesAsync.valueOrNull ?? const <Venue>[];
    final sports = ['Tất cả', ...loadedVenues.expand((venue) => venue.sport).toSet()];
    final selectedSport = sports.contains(_selectedSport) ? _selectedSport : sports.first;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(bottom: false, child: Column(children: [
        FieldSearchHeader(
          searchController: _searchController, focusNode: _focusNode, query: _query, showFilter: _showFilter, sports: sports, selectedSport: selectedSport,
          onQueryChanged: (value) => setState(() => _query = value), onClearSearch: () { _searchController.clear(); setState(() => _query = ''); },
          onToggleFilter: () => setState(() => _showFilter = !_showFilter), onSportSelected: (value) => setState(() => _selectedSport = value), onBack: widget.onBack,
        ),
        if (_showFilter) FieldFilterPanel(
          sorts: _sorts, selectedSort: _sortBy, onSortSelected: (value) => setState(() => _sortBy = value), maxPrice: _maxPrice, minRating: _minRating, onlyAvailable: _onlyAvailable,
          onMaxPriceChanged: (value) => setState(() => _maxPrice = value), onMinRatingChanged: (value) => setState(() => _minRating = value), onAvailabilityChanged: (value) => setState(() => _onlyAvailable = value),
          onReset: () => setState(() { _sortBy = _sorts.first; _maxPrice = null; _minRating = null; _onlyAvailable = false; }), onApply: () => setState(() => _showFilter = false),
        ),
        Expanded(child: venuesAsync.when(
          data: (venues) {
            final results = filterVenues(venues, VenueFilter(query: _query, sport: selectedSport, sort: _sortBy, maxPrice: _maxPrice, minRating: _minRating, onlyAvailable: _onlyAvailable));
            if (results.isEmpty) return const FieldSearchEmptyResults();
            return ListView.builder(physics: const BouncingScrollPhysics(), padding: const EdgeInsets.all(16), itemCount: results.length, itemBuilder: (_, index) { final venue = results[index]; return FieldCard(venue: venue, onTap: () => widget.onVenueTap(venue), onBook: () => widget.onVenueTap(venue)); });
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('Không tải được dữ liệu sân: $error', textAlign: TextAlign.center))),
        )),
      ])),
      bottomNavigationBar: CustomBottomNav(activeScreen: widget.activeNav, onNav: widget.onNav),
    );
  }
}
