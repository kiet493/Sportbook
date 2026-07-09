import 'package:flutter/material.dart';

class AuthHeader extends StatelessWidget {
  final String imageUrl;
  final double heightFactor;
  final List<Color> gradientColors;
  final List<double>? gradientStops;
  final VoidCallback? onBack;
  final bool showBrandBadge;

  const AuthHeader({
    super.key,
    required this.imageUrl,
    required this.heightFactor,
    required this.gradientColors,
    this.gradientStops,
    this.onBack,
    this.showBrandBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * heightFactor,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: gradientColors,
                  stops: gradientStops,
                ),
              ),
            ),
          ),
          if (onBack != null) _HeaderBackButton(onTap: onBack!),
          if (showBrandBadge) const _BrandBadge(),
        ],
      ),
    );
  }
}

class _HeaderBackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _HeaderBackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 48,
      left: 16,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.chevron_left, color: Color(0xFF0F172A)),
        ),
      ),
    );
  }
}

class _BrandBadge extends StatelessWidget {
  const _BrandBadge();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 16,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.flash_on,
                  size: 13,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              const Text.rich(
                TextSpan(
                  text: 'SPORT',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    letterSpacing: 1.2,
                  ),
                  children: [
                    TextSpan(
                      text: 'BOOK',
                      style: TextStyle(color: Color(0xFF2563EB)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
