import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/bottom_nav.dart';
import '../../providers/booking_providers.dart';
import '../../providers/firebase_providers.dart';
import 'widgets/widgets.dart';

class FavoritesPage extends ConsumerWidget {
  final Function(String) onNav;
  final String activeNav;

  const FavoritesPage({
    super.key,
    required this.onNav,
    required this.activeNav,
  });

  Future<void> _toggleFavorite(BuildContext context, WidgetRef ref, String venueId) async {
    final message = await ref.read(favoriteToggleProvider.notifier).toggle(venueId);
    if (!context.mounted || message == null) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(firebaseAuthStateProvider);
    final uid = auth.valueOrNull?.uid;
    final venues = ref.watch(publicVenuesProvider);
    final favoriteIds = uid == null
        ? const AsyncData<Set<String>>(<String>{})
        : ref.watch(favoriteVenueIdsProvider(uid));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: auth.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : uid == null
                  ? const _FavoritesMessage(
                      icon: Icons.lock_outline,
                      text: 'Vui lòng đăng nhập để xem danh sách yêu thích.',
                    )
                  : favoriteIds.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (error, _) => _FavoritesMessage(
                        icon: Icons.cloud_off_outlined,
                        text: _favoriteErrorMessage(error),
                      ),
                      data: (ids) => venues.when(
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (error, _) => _FavoritesMessage(
                          icon: Icons.cloud_off_outlined,
                          text: 'Không tải được danh sách sân: $error',
                        ),
                        data: (items) {
                          final favorites = items
                              .where((venue) => ids.contains(venue.firestoreId))
                              .toList(growable: false);
                          if (favorites.isEmpty) {
                            return FavoritesEmptyState(onExplore: () => onNav('home'));
                          }
                          return ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: favorites.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final venue = favorites[index];
                              return Card(
                                clipBehavior: Clip.antiAlias,
                                child: ListTile(
                                  leading: venue.image.isEmpty
                                      ? const CircleAvatar(child: Icon(Icons.sports_tennis))
                                      : CircleAvatar(backgroundImage: NetworkImage(venue.image)),
                                  title: Text(venue.name),
                                  subtitle: Text(venue.address.isEmpty ? venue.hours : venue.address),
                                  trailing: IconButton(
                                    tooltip: 'Bỏ yêu thích',
                                    icon: const Icon(Icons.favorite, color: Colors.red),
                                    onPressed: ref.watch(favoriteToggleProvider).isLoading
                                        ? null
                                        : () => _toggleFavorite(context, ref, venue.firestoreId),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(activeScreen: activeNav, onNav: onNav),
    );
  }

  Widget _buildHeader() => Container(
    alignment: Alignment.centerLeft,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
    ),
    child: const Text(
      'Yêu thích',
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
    ),
  );
}

class _FavoritesMessage extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FavoritesMessage({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: const Color(0xFF94A3B8)),
          const SizedBox(height: 12),
          Text(text, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}

String _favoriteErrorMessage(Object error) {
  if (error is FirebaseAuthRequiredException) return error.toString();
  final value = error.toString();
  if (value.contains('permission-denied')) return 'Bạn không có quyền xem danh sách yêu thích.';
  if (value.contains('unavailable')) return 'Không thể kết nối Firebase. Vui lòng thử lại.';
  return 'Không tải được danh sách yêu thích: $value';
}
