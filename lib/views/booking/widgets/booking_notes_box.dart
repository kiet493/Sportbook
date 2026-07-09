import 'package:flutter/material.dart';

/// Multi-line note input box.
class BookingNotesBox extends StatelessWidget {
  final TextEditingController controller;

  const BookingNotesBox({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: const [
              Icon(
                Icons.description_outlined,
                color: Color(0xFF2563EB),
                size: 16,
              ),
              SizedBox(width: 8),
              Text(
                "Ghi chú",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              controller: controller,
              maxLines: 3,
              style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
              decoration: const InputDecoration(
                hintText:
                    "Yêu cầu đặc biệt, ghi chú cho ban quản lý sân...",
                hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
