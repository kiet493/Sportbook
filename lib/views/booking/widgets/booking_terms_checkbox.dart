import 'package:flutter/material.dart';

/// Terms & conditions checkbox row.
class BookingTermsCheckbox extends StatelessWidget {
  final bool agreed;
  final ValueChanged<bool> onChanged;

  const BookingTermsCheckbox({
    super.key,
    required this.agreed,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!agreed),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 20,
              height: 20,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: agreed
                    ? const Color(0xFF2563EB)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: agreed
                      ? const Color(0xFF2563EB)
                      : const Color(0xFFCBD5E1),
                  width: 1.5,
                ),
              ),
              child: agreed
                  ? const Icon(
                      Icons.check,
                      size: 12,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                "Tôi đồng ý với điều khoản đặt sân và chính sách hủy lịch của SportBook.",
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
