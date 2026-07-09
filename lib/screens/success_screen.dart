import 'dart:math';
import 'package:flutter/material.dart';
import '../models/venue.dart';

class SuccessScreen extends StatefulWidget {
  final Venue venue;
  final VoidCallback onHome;
  final VoidCallback onViewBooking;

  const SuccessScreen({
    Key? key,
    required this.venue,
    required this.onHome,
    required this.onViewBooking,
  }) : super(key: key);

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> with SingleTickerProviderStateMixin {
  late AnimationController _confettiController;
  late List<ConfettiDot> _dots;
  final String _bookingId = "BK${Random().nextInt(90000) + 10000}";

  @override
  void initState() {
    super.initState();
    // Initialize falling confetti particles
    _dots = List.generate(24, (index) {
      final random = Random();
      return ConfettiDot(
        xRatio: random.nextDouble(),
        yInitial: -50 - random.nextDouble() * 150,
        speed: 100 + random.nextDouble() * 180,
        size: 6 + random.nextDouble() * 8,
        color: [
          const Color(0xFF2563EB),
          const Color(0xFF22C55E),
          const Color(0xFFF97316),
          const Color(0xFFA855F7),
          const Color(0xFFF59E0B),
        ][index % 5],
        swingWidth: 10 + random.nextDouble() * 20,
        swingSpeed: 2 + random.nextDouble() * 4,
      );
    });

    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _confettiController.forward();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Custom Confetti Painter
          AnimatedBuilder(
            animation: _confettiController,
            builder: (context, child) {
              return CustomPaint(
                painter: ConfettiPainter(
                  dots: _dots,
                  progress: _confettiController.value,
                ),
                child: Container(),
              );
            },
          ),

          // Main Success Layout
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 48),

                        // Success check circle with scale bounce animation
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.elasticOut,
                          builder: (context, val, child) {
                            return Transform.scale(
                              scale: val,
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF22C55E),
                                      Color(0xFF16A34A),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF22C55E).withOpacity(0.4),
                                      blurRadius: 32,
                                      offset: const Offset(0, 12),
                                    )
                                  ],
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 48,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),

                        // Title
                        const Text(
                          "Đặt sân thành công!",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Chúc bạn có một trận đấu tuyệt vời. Hẹn gặp trên sân!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Booking Card
                        _buildBookingCard(),
                        const SizedBox(height: 16),

                        // Optional ticket actions
                        Row(
                          children: [
                            Expanded(
                              child: _buildSecondaryActionButton(
                                icon: Icons.download_outlined,
                                label: "Lưu vé",
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildSecondaryActionButton(
                                icon: Icons.calendar_today_outlined,
                                label: "Thêm lịch",
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // Sticky Bottom Redirect actions
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: widget.onViewBooking,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.book_outlined, size: 18),
                            SizedBox(width: 8),
                            Text(
                              "Xem chi tiết đặt sân",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton(
                        onPressed: widget.onHome,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0F172A),
                          backgroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.home_outlined, size: 16),
                            SizedBox(width: 6),
                            Text(
                              "Về trang chủ",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          )
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Header info (Mã đặt sân & thumbnail)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Mã đặt sân",
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  Text(
                    "#$_bookingId",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: NetworkImage(widget.venue.image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFE2E8F0), height: 1.0, thickness: 1.0),
          const SizedBox(height: 16),

          // Detail rows
          _buildDetailRow(Icons.location_on, "Sân", widget.venue.name),
          const SizedBox(height: 10),
          _buildDetailRow(Icons.calendar_today, "Ngày", "Thứ 7, 12/07/2025"),
          const SizedBox(height: 10),
          _buildDetailRow(Icons.access_time, "Giờ", "19:00 – 20:00"),
          const SizedBox(height: 10),
          _buildDetailRow(Icons.flash_on, "Môn", widget.venue.sport[0]),
          const SizedBox(height: 10),
          _buildDetailRow(Icons.credit_card, "Thanh toán", "Đã thanh toán ✓", isGreenText: true),

          const SizedBox(height: 16),
          const Divider(color: Color(0xFFE2E8F0), height: 1.0, thickness: 1.0),
          const SizedBox(height: 14),

          // QR Code check-in block
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Icon(
                  Icons.qr_code,
                  color: Color(0xFF64748B),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "QR Check-in",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Xuất trình khi đến sân",
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String val, {bool isGreenText = false}) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB).withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 14,
            color: const Color(0xFF2563EB),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          val,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isGreenText ? const Color(0xFF15803D) : const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _buildSecondaryActionButton({required IconData icon, required String label}) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF0F172A),
        backgroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 44),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

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

class ConfettiPainter extends CustomPainter {
  final List<ConfettiDot> dots;
  final double progress;

  ConfettiPainter({required this.dots, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (var dot in dots) {
      final elapsedSeconds = progress * 4.0;
      double y = dot.yInitial + dot.speed * elapsedSeconds;

      // Wrap around or cap at height
      if (y > size.height) continue;

      // Add a waving effect on x coordinate
      double swing = sin(elapsedSeconds * dot.swingSpeed) * dot.swingWidth;
      double x = (dot.xRatio * size.width) + swing;

      // Draw confetti particle (as a tiny rectangle or circle)
      final paint = Paint()
        ..color = dot.color
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      // Add slight rotation
      canvas.rotate(elapsedSeconds * 4.0 * (dot.xRatio > 0.5 ? 1 : -1));
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: dot.size, height: dot.size * 0.6),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant ConfettiPainter oldDelegate) => true;
}
