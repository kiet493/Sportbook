import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/venue.dart';
import 'home_venue_card.dart';

/// "Sân gần bạn" section: header row + scrollable list of [HomeVenueCard]s.
class HomeNearbySection extends StatelessWidget {
  final List<Venue> venues;
  final Set<int> favorites;
  final ValueChanged<Venue> onVenueTap;
  final ValueChanged<int> onToggleFavorite;

  const HomeNearbySection({
    super.key,
    required this.venues,
    required this.favorites,
    required this.onVenueTap,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Sân gần bạn',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Xem tất cả',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: venues.length,
          itemBuilder: (context, index) {
            final venue = venues[index];
            return HomeVenueCard(
              venue: venue,
              isFavorite: favorites.contains(venue.id),
              onTap: () => onVenueTap(venue),
              onBook: () => onVenueTap(venue),
              onFavoriteTap: () => onToggleFavorite(venue.id),
            );
          },
        ),
      ],
    );
  }
}
