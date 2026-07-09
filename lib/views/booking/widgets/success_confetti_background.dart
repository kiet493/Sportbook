import 'dart:math';

import 'package:flutter/material.dart';

/// Particle data for the falling confetti background.
class ConfettiDot {
  final double xRatio;
  final double yInitial;
  final double speed;
  final double size;
  final Color color;
  final double swingWidth;
  final double swingSpeed;

  ConfettiDot({
    required this.xRatio,
    required this.yInitial,
    required this.speed,
    required this.size,
    required this.color,
    required this.swingWidth,
    required this.swingSpeed,
  });
}

/// Paints a list of [ConfettiDot] particles using the current
/// [progress] (0..1) to determine their vertical offset.
class ConfettiPainter extends CustomPainter {
  final List<ConfettiDot> dots;
  final double progress;

  ConfettiPainter({required this.dots, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final elapsedSeconds = progress * 4.0;
    for (final dot in dots) {
      final y = dot.yInitial + dot.speed * elapsedSeconds;
      if (y > size.height) continue;

      final swing = sin(elapsedSeconds * dot.swingSpeed) * dot.swingWidth;
      final x = (dot.xRatio * size.width) + swing;

      final paint = Paint()
        ..color = dot.color
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(elapsedSeconds * 4.0 * (dot.xRatio > 0.5 ? 1 : -1));
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: dot.size,
          height: dot.size * 0.6,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant ConfettiPainter oldDelegate) => true;
}

/// Builds the static list of [ConfettiDot] for a one-shot burst.
List<ConfettiDot> buildConfettiDots({int count = 24}) {
  const palette = [
    Color(0xFF2563EB),
    Color(0xFF22C55E),
    Color(0xFFF97316),
    Color(0xFFA855F7),
    Color(0xFFF59E0B),
  ];
  return List.generate(count, (index) {
    final random = Random();
    return ConfettiDot(
      xRatio: random.nextDouble(),
      yInitial: -50 - random.nextDouble() * 150,
      speed: 100 + random.nextDouble() * 180,
      size: 6 + random.nextDouble() * 8,
      color: palette[index % palette.length],
      swingWidth: 10 + random.nextDouble() * 20,
      swingSpeed: 2 + random.nextDouble() * 4,
    );
  });
}

/// Animated full-screen confetti background driven by [controller].
class SuccessConfettiBackground extends StatelessWidget {
  final AnimationController controller;
  final List<ConfettiDot> dots;

  const SuccessConfettiBackground({
    super.key,
    required this.controller,
    required this.dots,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return CustomPaint(
          painter: ConfettiPainter(
            dots: dots,
            progress: controller.value,
          ),
          child: Container(),
        );
      },
    );
  }
}
