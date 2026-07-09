import 'package:flutter/material.dart';
import '../models/venue.dart';
import '../widgets/bottom_nav.dart';

class SearchScreen extends StatefulWidget {
  final VoidCallback onBack;
  final Function(Venue) onVenueTap;
  final Function(String) onNav;
  final String activeNav;

  const SearchScreen({
    Key? key,
    required this.onBack,
    required this.onVenueTap,
    required this.onNav,
    required this.activeNav,
  }) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _query = "";
  bool _showFilter = false;
  String _sortBy = "Gần nhất";
  String _selectedSport = "Tất cả";

  final List<String> _recentSearches = List.from(RECENT_SEARCHES);

  @override
  void initState() {
    super.initState();
    // Auto focus search input
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<Venue> _getFilteredResults() {
    return VENUES.where((v) {
      // 1. Query filter (matches venue name or sport tag)
      bool matchesQuery = _query.isEmpty ||
          v.name.toLowerCase().contains(_query.toLowerCase()) ||
          v.sport.any((s) => s.toLowerCase().contains(_query.toLowerCase()));

      // 2. Sport category filter
      bool matchesSport = _selectedSport == "Tất cả" ||
          v.sport.any((s) => s.toLowerCase() == _selectedSport.toLowerCase());

      return matchesQuery && matchesSport;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final results = _getFilteredResults();
    final sports = ["Tất cả", ...SPORTS_CATEGORIES.map((s) => s.name)];
    final sorts = ["Gần nhất", "Đánh giá cao", "Giá thấp nhất", "Phổ biến nhất"];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Search Header
            _buildSearchHeader(sports),

            // Sorting Panel (if shown)
            if (_showFilter) _buildFilterPanel(sorts),

            // Scrollable Content
            Expanded(
              child: _query.isEmpty
                  ? _buildDefaultSearchesSection()
                  : _buildSearchResultsSection(results),
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

  Widget _buildSearchHeader(List<String> sports) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE2E8F0),
            width: 1.0,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Back Button
              GestureDetector(
                onTap: widget.onBack,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.chevron_left,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Search Input Box
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search,
                        color: Color(0xFF94A3B8),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          focusNode: _focusNode,
                          onChanged: (val) {
                            setState(() {
                              _query = val;
                            });
                          },
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F172A),
                          ),
                          decoration: const InputDecoration(
                            hintText: "Tìm sân, môn thể thao...",
                            hintStyle: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                      if (_query.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            setState(() {
                              _query = "";
                            });
                          },
                          child: const Icon(
                            Icons.close,
                            color: Color(0xFF94A3B8),
                            size: 16,
                          ),
                        ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.mic_none,
                        color: Color(0xFF94A3B8),
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Filter Toggle Button
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showFilter = !_showFilter;
                  });
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _showFilter ? const Color(0xFF2563EB) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _showFilter ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.filter_list,
                    color: _showFilter ? Colors.white : const Color(0xFF64748B),
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Horizontal Category Chips
          SizedBox(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: sports.length,
              itemBuilder: (context, index) {
                final sport = sports[index];
                final isSelected = _selectedSport == sport;
                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: ChoiceChip(
                    label: Text(
                      sport,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : const Color(0xFF64748B),
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedSport = sport;
                        });
                      }
                    },
                    selectedColor: const Color(0xFF2563EB),
                    backgroundColor: Colors.white,
                    pressElevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                        width: 1.0,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPanel(List<String> sorts) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE2E8F0),
            width: 1.0,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Sắp xếp theo",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: sorts.map((s) {
              final isSelected = _sortBy == s;
              return ChoiceChip(
                label: Text(
                  s,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _sortBy = s;
                    });
                  }
                },
                selectedColor: const Color(0xFF2563EB),
                backgroundColor: const Color(0xFFF1F5F9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _showFilter = false;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Áp dụng bộ lọc",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultSearchesSection() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Recent Searches Header
          if (_recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Tìm kiếm gần đây",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _recentSearches.clear();
                    });
                  },
                  child: const Text(
                    "Xóa tất cả",
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF2563EB),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Recent list
            Column(
              children: _recentSearches.map((s) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ListTile(
                    onTap: () {
                      _searchController.text = s;
                      setState(() {
                        _query = s;
                      });
                    },
                    tileColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    leading: const Icon(
                      Icons.schedule,
                      color: Color(0xFF94A3B8),
                      size: 16,
                    ),
                    title: Text(
                      s,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward,
                      color: Color(0xFF94A3B8),
                      size: 14,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 0,
                    ),
                    dense: true,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],

          // Popular Keywords
          const Text(
            "Phổ biến",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: POPULAR_SEARCHES.map((s) {
              return ActionChip(
                onPressed: () {
                  _searchController.text = s;
                  setState(() {
                    _query = s;
                  });
                },
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                avatar: const Icon(
                  Icons.trending_up,
                  color: Color(0xFF2563EB),
                  size: 14,
                ),
                label: Text(
                  s,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultsSection(List<Venue> results) {
    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
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
                  Icons.search_off,
                  color: Color(0xFF94A3B8),
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Không tìm thấy kết quả",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Thử từ khóa khác hoặc điều chỉnh bộ lọc.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final venue = results[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: GestureDetector(
            onTap: () => widget.onVenueTap(venue),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Venue Image Stack
                  Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 9.5,
                        child: Image.network(
                          venue.image,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black38,
                              ],
                              stops: [0.55, 1.0],
                            ),
                          ),
                        ),
                      ),

                      // Sports badge overlays
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Row(
                          children: venue.sport.map((s) {
                            return Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                s,
                                style: const TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),

                  // Details
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                venue.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF7ED),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFFFFEDD5),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 11,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "${venue.rating}",
                                    style: const TextStyle(
                                      color: Color(0xFFC2410C),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Meta details
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              color: Color(0xFF94A3B8),
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              venue.distance,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Icon(
                              Icons.access_time_outlined,
                              color: Color(0xFF94A3B8),
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              venue.hours,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Pricing and action
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              venue.price,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () => widget.onVenueTap(venue),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                minimumSize: const Size(80, 32),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                "Đặt ngay",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
