import 'package:flutter/material.dart';

class FieldImageGallery extends StatefulWidget {
  final List<String> images;
  final VoidCallback onBack;
  final VoidCallback onShare;
  final VoidCallback onFavorite;
  final bool isFavorite;

  const FieldImageGallery({
    super.key,
    required this.images,
    required this.onBack,
    required this.onShare,
    required this.onFavorite,
    required this.isFavorite,
  });

  @override
  State<FieldImageGallery> createState() => _FieldImageGalleryState();
}

class _FieldImageGalleryState extends State<FieldImageGallery> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            itemCount: widget.images.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              return Image.network(widget.images[index], fit: BoxFit.cover);
            },
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black38, Colors.transparent],
                stops: [0.0, 0.4],
              ),
            ),
          ),
          _HeaderActions(
            onBack: widget.onBack,
            onShare: widget.onShare,
            onFavorite: widget.onFavorite,
            isFavorite: widget.isFavorite,
          ),
          if (widget.images.length > 1) _DotIndicator(
            count: widget.images.length,
            currentIndex: _currentIndex,
          ),
          _ImageCounter(
            current: _currentIndex + 1,
            total: widget.images.length,
          ),
        ],
      ),
    );
  }
}

class _HeaderActions extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onShare;
  final VoidCallback onFavorite;
  final bool isFavorite;

  const _HeaderActions({
    required this.onBack,
    required this.onShare,
    required this.onFavorite,
    required this.isFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 48,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _ActionButton(icon: Icons.chevron_left, onTap: onBack),
          Row(
            children: [
              _ActionButton(icon: Icons.share_outlined, onTap: onShare),
              const SizedBox(width: 8),
              _ActionButton(
                icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                iconColor: isFavorite ? Colors.red : Colors.white,
                onTap: onFavorite,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  const _ActionButton({
    required this.icon,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.20),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          icon,
          color: iconColor ?? Colors.white,
          size: 18,
        ),
      ),
    );
  }
}

class _DotIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;

  const _DotIndicator({required this.count, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 12,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          count,
          (i) => AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            height: 6,
            width: currentIndex == i ? 20 : 6,
            decoration: BoxDecoration(
              color: currentIndex == i ? Colors.white : Colors.white60,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      ),
    );
  }
}

class _ImageCounter extends StatelessWidget {
  final int current;
  final int total;

  const _ImageCounter({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 12,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          "$current/$total",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
