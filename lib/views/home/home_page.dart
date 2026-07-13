import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/bottom_nav.dart';
import '../../models/venue.dart';
import '../../providers/booking_providers.dart';
import '../../providers/registration_providers.dart';
import 'widgets/widgets.dart';

class HomePage extends ConsumerStatefulWidget {
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
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String _activeFeature = 'Sân trong nhà';
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
    final user = ref.watch(sessionProvider)?.user;
    final fullName = user?.fullName.trim();
    final address = user?.address.trim();
    final avatarUrl = user?.avatarUrl.trim();
    final venuesAsync = ref.watch(publicVenuesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            HomeHeader(
              greeting: 'Chào buổi sáng,',
              name:
                  '${(fullName == null || fullName.isEmpty) ? 'Bạn' : fullName} 👋',
              location: (address == null || address.isEmpty)
                  ? 'Chưa cập nhật địa chỉ'
                  : address,
              avatarUrl: avatarUrl ?? '',
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
                      categories: BADMINTON_FEATURES,
                      activeSport: _activeFeature,
                      onSportSelected: (feature) =>
                          setState(() => _activeFeature = feature),
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
                    venuesAsync.when(
                      data: (venues) => venues.isEmpty
                          ? const _HomeVenuesMessage(
                              message:
                                  'Chưa có dữ liệu sân trên Firebase. Hãy chạy seed data.',
                            )
                          : HomeNearbySection(
                              venues: venues,
                              favorites: _favorites,
                              onVenueTap: widget.onVenueTap,
                              onToggleFavorite: _toggleFavorite,
                            ),
                      error: (error, _) => _HomeVenuesMessage(
                        message: 'Không tải được dữ liệu sân: $error',
                      ),
                      loading: () => const SizedBox(
                        height: 180,
                        child: Center(child: CircularProgressIndicator()),
                      ),
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

class _HomeVenuesMessage extends StatelessWidget {
  final String message;

  const _HomeVenuesMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Color(0xFF64748B)),
      ),
    );
  }
}
