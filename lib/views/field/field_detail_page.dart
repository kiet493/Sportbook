import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/court_booking.dart';
import '../../models/venue.dart';
import '../../providers/booking_providers.dart';
import '../../providers/firebase_providers.dart';
import 'widgets/widgets.dart';

class FieldDetailPage extends ConsumerStatefulWidget {
  final Venue venue;
  final VoidCallback onBack;
  final VoidCallback onBook;
  final ValueChanged<Venue> onVenueTap;
  final Function(String) onNav;
  final String activeNav;

  const FieldDetailPage({
    super.key,
    required this.venue,
    required this.onBack,
    required this.onBook,
    required this.onVenueTap,
    required this.onNav,
    required this.activeNav,
  });

  @override
  ConsumerState<FieldDetailPage> createState() => _FieldDetailPageState();
}

class _FieldDetailPageState extends ConsumerState<FieldDetailPage> {
  String _selectedDate = "Hôm nay";
  String? _selectedSlot;
  final List<String> _dates = const [];

  Future<void> _toggleFavorite() async {
    final message = await ref
        .read(favoriteToggleProvider.notifier)
        .toggle(widget.venue.firestoreId);
    if (!mounted || message == null) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final firebaseUser = ref.watch(firebaseAuthStateProvider).valueOrNull;
    final favoriteIds = firebaseUser == null
        ? const <String>{}
        : ref.watch(favoriteVenueIdsProvider(firebaseUser.uid)).valueOrNull ??
            const <String>{};
    final isFavorite = favoriteIds.contains(widget.venue.firestoreId);
    final similarVenues = ref
            .watch(publicVenuesProvider)
            .valueOrNull
            ?.where((v) => v.firestoreId != widget.venue.firestoreId)
            .take(3)
            .toList(growable: false) ??
        const <Venue>[];
    final AsyncValue<List<SportCourt>> courtsAsync = ref.watch(
      venueCourtsProvider(widget.venue.firestoreId),
    );
    final List<SportCourt> courts =
        courtsAsync.valueOrNull ?? const <SportCourt>[];
    final List<String> amenities = courts
        .expand<String>((court) => court.amenities)
        .toSet()
        .toList(growable: false);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FieldImageGallery(
                    images: widget.venue.images,
                    onBack: widget.onBack,
                    onShare: () {},
                    onFavorite: _toggleFavorite,
                    isFavorite: isFavorite,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildTitleSection(),
                        const SizedBox(height: 10),
                        FieldSportsTags(sports: widget.venue.sport),
                        const SizedBox(height: 12),
                        FieldMetaInfo(
                          address: widget.venue.address,
                          hours: widget.venue.hours,
                          distance: widget.venue.distance,
                        ),
                        const SizedBox(height: 16),
                        _buildPricingCallout(),
                        const SizedBox(height: 16),
                        const Divider(color: Color(0xFFE2E8F0)),
                        const SizedBox(height: 16),
                        _buildDescriptionSection(),
                        const SizedBox(height: 20),
                        if (amenities.isNotEmpty) _buildAmenitiesSection(amenities),
                        const SizedBox(height: 20),
                        if (similarVenues.isNotEmpty)
                          FieldSimilarVenues(
                            venues: similarVenues,
                            onVenueTap: widget.onVenueTap,
                          ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            widget.venue.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(width: 8),
        FieldRatingBadge(
          rating: widget.venue.rating,
          reviewCount: widget.venue.reviews,
          fontSize: 12,
          iconSize: 13,
        ),
      ],
    );
  }

  Widget _buildPricingCallout() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2563EB).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2563EB).withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Giá thuê sân",
                style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
              Text(
                widget.venue.price,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF2563EB),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: const Text(
              "Mở cửa",
              style: TextStyle(
                color: Color(0xFF15803D),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "Mô tả",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.venue.description,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF64748B),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildAmenitiesSection(List<String> amenities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "Tiện ích",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),
        FieldAmenitiesGrid(amenities: amenities),
      ],
    );
  }

  Widget _buildTimeSlotsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "Khung giờ trống",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 10),
        FieldTimeSlotPicker(
          dates: _dates,
          timeSlots: const <TimeSlot>[],
          selectedDate: _selectedDate,
          selectedSlot: _selectedSlot,
          onDateSelected: (d) => setState(() => _selectedDate = d),
          onSlotSelected: (s) => setState(() => _selectedSlot = s),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24, top: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.96),
          border: const Border(
            top: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
          ),
        ),
        child: ElevatedButton(
          onPressed: widget.onBook,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.book_online, size: 18),
              const SizedBox(width: 8),
              Text(
                _selectedSlot != null ? "Đặt sân lúc $_selectedSlot" : "Đặt sân ngay",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
