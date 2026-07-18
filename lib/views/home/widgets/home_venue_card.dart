import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/venue.dart';

/// Full venue card displayed in the "Nearby" section on the Home page.
///
/// Renders an image stack (gradient overlay, sport-type tags, availability
/// badge, favourite toggle) followed by an info panel with name, rating,
/// meta data, price, and a booking button.
class HomeVenueCard extends StatelessWidget {
  final Venue venue;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onBook;
  final VoidCallback onFavoriteTap;

  const HomeVenueCard({
    super.key,
    required this.venue,
    required this.isFavorite,
    required this.onTap,
    required this.onBook,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _VenueImageStack(
                venue: venue,
                isFavorite: isFavorite,
                onFavoriteTap: onFavoriteTap,
              ),
              _VenueInfoPanel(venue: venue, onBook: onBook),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Private sub-widgets ────────────────────────────────────────────────────

class _VenueImageStack extends StatelessWidget {
  final Venue venue;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;

  const _VenueImageStack({
    required this.venue,
    required this.isFavorite,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: venue.image.isEmpty
              ? const ColoredBox(
                  color: Color(0xFFE2E8F0),
                  child: Center(child: Icon(Icons.sports_tennis, color: Color(0xFF64748B), size: 40)),
                )
              : Image.network(venue.image, fit: BoxFit.cover, errorBuilder: (_, _, _) => const ColoredBox(color: Color(0xFFE2E8F0))),
        ),
        // Bottom gradient
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black38],
                stops: [0.55, 1.0],
              ),
            ),
          ),
        ),
        // Sport-type tags (top-left)
        Positioned(
          top: 12,
          left: 12,
          child: Row(
            children: venue.sport.map((s) => _SportTag(label: s)).toList(),
          ),
        ),
        // Available badge (bottom-left)
        if (venue.available)
          const Positioned(
            bottom: 12,
            left: 12,
            child: _AvailableBadge(),
          ),
        // Favourite toggle (top-right)
        Positioned(
          top: 12,
          right: 12,
          child: _FavoriteButton(
            isFavorite: isFavorite,
            onTap: onFavoriteTap,
          ),
        ),
      ],
    );
  }
}

class _SportTag extends StatelessWidget {
  final String label;

  const _SportTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _AvailableBadge extends StatelessWidget {
  const _AvailableBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF22C55E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.check_circle_outline, color: Colors.white, size: 10),
          SizedBox(width: 4),
          Text(
            'Còn chỗ hôm nay',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onTap;

  const _FavoriteButton({required this.isFavorite, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
            ),
          ],
        ),
        child: Icon(
          Icons.favorite,
          size: 16,
          color: isFavorite ? Colors.red : AppColors.textMuted,
        ),
      ),
    );
  }
}

class _VenueInfoPanel extends StatelessWidget {
  final Venue venue;
  final VoidCallback onBook;

  const _VenueInfoPanel({required this.venue, required this.onBook});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name + Rating row
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
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _RatingBadge(rating: venue.rating, reviews: venue.reviews),
            ],
          ),
          const SizedBox(height: 8),
          // Meta row
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  color: AppColors.textMuted, size: 13),
              const SizedBox(width: 4),
              Text(venue.distance,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary)),
              const SizedBox(width: 16),
              const Icon(Icons.access_time_outlined,
                  color: AppColors.textMuted, size: 13),
              const SizedBox(width: 4),
              Text(venue.hours,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 12),
          // Price + Book button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                venue.price,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
              ElevatedButton(
                onPressed: onBook,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size(80, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Đặt ngay',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  final double rating;
  final int reviews;

  const _RatingBadge({required this.rating, required this.reviews});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFEDD5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.star, color: Colors.amber, size: 12),
          const SizedBox(width: 4),
          Text(
            '$rating',
            style: const TextStyle(
              color: Color(0xFFC2410C),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 2),
          Text(
            '($reviews)',
            style: const TextStyle(color: Color(0xFFF97316), fontSize: 10),
          ),
        ],
      ),
    );
  }
}
