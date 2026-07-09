import 'package:flutter/material.dart';

/// Secondary outlined action button (used in the "Lưu vé" / "Thêm lịch"
/// row on the success page).
class SuccessSecondaryActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const SuccessSecondaryActionButton({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
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

/// Sticky bottom action bar with primary "Xem chi tiết" and
/// secondary "Về trang chủ" buttons.
class SuccessBottomActions extends StatelessWidget {
  final VoidCallback onViewBooking;
  final VoidCallback onHome;

  const SuccessBottomActions({
    super.key,
    required this.onViewBooking,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: onViewBooking,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
            onPressed: onHome,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF0F172A),
              backgroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
    );
  }
}
