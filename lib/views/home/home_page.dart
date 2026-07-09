import 'package:flutter/material.dart';

import '../../core/widgets/bottom_nav.dart';
import '../../models/venue.dart';
import 'widgets/widgets.dart';

class HomePage extends StatefulWidget {
  final Function(Venue) onVenueTap;
  final Function(String) onNav;
  final String activeNav;

  const HomePage({
    super.key,
    required this.onVenueTap,
    required this.onNav,
    required this.activeNav,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _activeSport = 'Bóng đá';
  String _activeFilter = 'Tất cả';
  final Set<int> _favorites = {2};

  void _toggleFavorite(int venueId) {
    setState(() {
      if (_favorites.contains(venueId)) {
        _favorites.remove(venueId);
      } else {
        _favorites.add(venueId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            HomeHeader(
              greeting: 'Chào buổi sáng,',
              name: 'Minh Tuấn 👋',
              location: 'Quận 7, TP.HCM',
              avatarUrl:
                  'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=80&h=80&fit=crop&auto=format',
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    HomeSearchBar(onTap: () => widget.onNav('search')),
                    HomeSportsSection(
                      categories: SPORTS_CATEGORIES,
                      activeSport: _activeSport,
                      onSportSelected: (sport) =>
                          setState(() => _activeSport = sport),
                      onSeeMore: () => widget.onNav('search'),
                    ),
                    HomeBannerCarousel(banners: BANNERS),
                    const SizedBox(height: 8),
                    HomeQuickFilters(
                      filters: QUICK_FILTERS,
                      activeFilter: _activeFilter,
                      onFilterSelected: (filter) =>
                          setState(() => _activeFilter = filter),
                    ),
                    HomeNearbySection(
                      venues: VENUES,
                      favorites: _favorites,
                      onVenueTap: widget.onVenueTap,
                      onToggleFavorite: _toggleFavorite,
                    ),
                  ],
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
