import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/bottom_nav.dart';
import '../../models/venue.dart';
import '../../providers/booking_providers.dart';
import '../../providers/firebase_providers.dart';
import '../../providers/registration_providers.dart';
import '../../providers/notification_providers.dart';
import '../../core/utils/venue_filter.dart';
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
  String _activeFilter = 'Tất cả';
  Future<void> _toggleFavorite(Venue venue) async {
    final message = await ref
        .read(favoriteToggleProvider.notifier)
        .toggle(venue.firestoreId);
    if (!mounted || message == null) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(sessionProvider)?.user;
    final fullName = user?.fullName.trim();
    final address = user?.address.trim();
    final avatarUrl = user?.avatarUrl.trim();
    final venuesAsync = ref.watch(publicVenuesProvider);
    final unreadNotifications = ref.watch(userNotificationsProvider)
        .valueOrNull
        ?.any((notification) => !notification.read) ?? false;
    final firebaseUser = ref.watch(firebaseAuthStateProvider).valueOrNull;
    final favoriteIds = firebaseUser == null
        ? const <String>{}
        : ref.watch(favoriteVenueIdsProvider(firebaseUser.uid)).valueOrNull ??
              const <String>{};

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
              hasNotification: unreadNotifications,
              onNotificationsTap: () => widget.onNav('notifications'),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    HomeSearchBar(onTap: () => widget.onNav('search')),
                    HomeQuickFilters(
                      filters: const [
                        'Tất cả',
                        'Sự kiện',
                        'Ghép đội',
                        'Đánh giá cao',
                        'Mở ngay',
                      ],
                      activeFilter: _activeFilter,
                      onFilterSelected: (filter) {
                        if (filter == 'Sự kiện') {
                          widget.onNav('events');
                          return;
                        }
                        if (filter == 'Ghép đội') {
                          widget.onNav('matchmaking');
                          return;
                        }
                        setState(() => _activeFilter = filter);
                      },
                    ),
                    venuesAsync.when(
                      data: (venues) {
                        final filtered = filterVenues(venues, _homeFilter);
                        return filtered.isEmpty
                            ? const _HomeVenuesMessage(
                                message: 'Chưa có dữ liệu sân trên Firebase.',
                              )
                            : HomeNearbySection(
                                venues: filtered,
                                favorites: filtered
                                    .where(
                                      (venue) => favoriteIds.contains(
                                        venue.firestoreId,
                                      ),
                                    )
                                    .map((venue) => venue.id)
                                    .toSet(),
                                onVenueTap: widget.onVenueTap,
                                onToggleFavorite: _toggleFavorite,
                              );
                      },
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

  VenueFilter get _homeFilter {
    final index = const [
      'Tất cả',
      'Đánh giá cao',
      'Mở ngay',
    ].indexOf(_activeFilter);
    switch (index) {
      case 1:
        return const VenueFilter(sort: 'Đánh giá cao');
      case 2:
        return const VenueFilter(onlyAvailable: true);
      default:
        return const VenueFilter();
    }
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
