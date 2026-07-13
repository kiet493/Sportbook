import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/venue.dart';
import '../../providers/booking_providers.dart';
import '../../core/widgets/bottom_nav.dart';
import 'widgets/widgets.dart';

class FieldSearchPage extends ConsumerStatefulWidget {
  final VoidCallback onBack;
  final Function(Venue) onVenueTap;
  final Function(String) onNav;
  final String activeNav;

  const FieldSearchPage({
    super.key,
    required this.onBack,
    required this.onVenueTap,
    required this.onNav,
    required this.activeNav,
  });

  @override
  ConsumerState<FieldSearchPage> createState() => _FieldSearchPageState();
}

class _FieldSearchPageState extends ConsumerState<FieldSearchPage> {
  final _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _query = "";
  bool _showFilter = false;
  String _sortBy = "Gần nhất";
  String _selectedSport = "Tất cả";
  final List<String> _recentSearches = List.from(RECENT_SEARCHES);

  final _sports = ["Tất cả", ...BADMINTON_SPORT_FILTERS];
  final _sorts = ["Gần nhất", "Đánh giá cao", "Giá thấp nhất", "Phổ biến nhất"];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<Venue> _getFilteredResults(List<Venue> venues) {
    return venues.where((v) {
      final matchesQuery = _query.isEmpty ||
          v.name.toLowerCase().contains(_query.toLowerCase()) ||
          v.sport.any((s) => s.toLowerCase().contains(_query.toLowerCase()));
      final matchesSport = _selectedSport == "Tất cả" ||
          v.sport.any((s) => s.toLowerCase() == _selectedSport.toLowerCase());
      return matchesQuery && matchesSport;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final venuesAsync = ref.watch(publicVenuesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            FieldSearchHeader(
              searchController: _searchController,
              focusNode: _focusNode,
              query: _query,
              showFilter: _showFilter,
              sports: _sports,
              selectedSport: _selectedSport,
              onQueryChanged: (val) => setState(() => _query = val),
              onClearSearch: () {
                _searchController.clear();
                setState(() => _query = "");
              },
              onToggleFilter: () => setState(() => _showFilter = !_showFilter),
              onSportSelected: (sport) => setState(() => _selectedSport = sport),
              onBack: widget.onBack,
            ),
            if (_showFilter)
              FieldFilterPanel(
                sorts: _sorts,
                selectedSort: _sortBy,
                onSortSelected: (s) => setState(() => _sortBy = s),
                onApply: () => setState(() => _showFilter = false),
              ),
            Expanded(
              child: venuesAsync.when(
                data: (venues) {
                  final results = _getFilteredResults(venues);
                  return _query.isEmpty
                      ? FieldSearchEmptyState(
                          recentSearches: _recentSearches,
                          popularSearches: POPULAR_SEARCHES,
                          onRecentTap: (s) {
                            _searchController.text = s;
                            setState(() => _query = s);
                          },
                          onPopularTap: (s) {
                            _searchController.text = s;
                            setState(() => _query = s);
                          },
                          onClearRecent: () =>
                              setState(() => _recentSearches.clear()),
                        )
                      : results.isEmpty
                          ? const FieldSearchEmptyResults()
                          : _buildResultsList(results);
                },
                error: (error, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Không tải được dữ liệu sân: $error',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
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

  Widget _buildResultsList(List<Venue> results) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final venue = results[index];
        return FieldCard(
          venue: venue,
          onTap: () => widget.onVenueTap(venue),
          onBook: () => widget.onVenueTap(venue),
        );
      },
    );
  }
}
