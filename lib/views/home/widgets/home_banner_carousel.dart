import 'dart:async';

import 'package:flutter/material.dart';

import '../../../models/venue.dart';

/// Auto-advancing promotional banner carousel with page-indicator dots.
///
/// Owns its own [PageController] and [Timer] so the parent page stays lean.
class HomeBannerCarousel extends StatefulWidget {
  final List<BannerInfo> banners;

  const HomeBannerCarousel({super.key, required this.banners});

  @override
  State<HomeBannerCarousel> createState() => _HomeBannerCarouselState();
}

class _HomeBannerCarouselState extends State<HomeBannerCarousel> {
  int _activeIndex = 0;
  final PageController _controller = PageController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 3500), (_) {
      if (_controller.hasClients) {
        final next = (_activeIndex + 1) % widget.banners.length;
        _controller.animateToPage(
          next,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: widget.banners.length,
              onPageChanged: (i) => setState(() => _activeIndex = i),
              itemBuilder: (context, index) =>
                  _BannerSlide(banner: widget.banners[index]),
            ),
            Positioned(
              bottom: 12,
              right: 16,
              child: _IndicatorDots(
                count: widget.banners.length,
                activeIndex: _activeIndex,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Private sub-widgets ────────────────────────────────────────────────────

class _BannerSlide extends StatelessWidget {
  final BannerInfo banner;

  const _BannerSlide({required this.banner});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(banner.image, fit: BoxFit.cover),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                banner.color.withValues(alpha: 0.85),
                banner.color.withValues(alpha: 0.4),
                Colors.transparent,
              ],
              stops: const [0.0, 0.55, 1.0],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                banner.sub,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                banner.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _BannerCtaButton(label: banner.cta),
            ],
          ),
        ),
      ],
    );
  }
}

class _BannerCtaButton extends StatelessWidget {
  final String label;

  const _BannerCtaButton({required this.label});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        minimumSize: const Size(80, 32),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_forward, size: 10),
        ],
      ),
    );
  }
}

class _IndicatorDots extends StatelessWidget {
  final int count;
  final int activeIndex;

  const _IndicatorDots({required this.count, required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(count, (i) {
        final isActive = i == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.only(left: 4),
          height: 6,
          width: isActive ? 20 : 6,
          decoration: BoxDecoration(
            color: isActive
                ? Colors.white
                : Colors.white.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}
