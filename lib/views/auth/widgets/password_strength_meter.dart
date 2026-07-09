import 'package:flutter/material.dart';

class PasswordStrengthMeter extends StatelessWidget {
  final int strength;

  const PasswordStrengthMeter({super.key, required this.strength});

  Color get _color {
    switch (strength) {
      case 1:
        return const Color(0xFFEF4444);
      case 2:
        return const Color(0xFFF97316);
      case 3:
        return const Color(0xFFEAB308);
      case 4:
        return const Color(0xFF22C55E);
      default:
        return Colors.transparent;
    }
  }

  String get _label {
    switch (strength) {
      case 1:
        return "Yếu";
      case 2:
        return "Trung bình";
      case 3:
        return "Khá";
      case 4:
        return "Mạnh";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: List.generate(
                4,
                (i) => Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: i < strength ? _color : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 70,
            child: Text(
              _label,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: _color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
