import 'package:flutter/material.dart';

class FieldRatingBadge extends StatelessWidget {
  final double rating;
  final int? reviewCount;
  final double fontSize;
  final double iconSize;

  const FieldRatingBadge({
    super.key,
    required this.rating,
    this.reviewCount,
    this.fontSize = 12,
    this.iconSize = 13,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFEDD5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, color: Colors.amber, size: iconSize),
          const SizedBox(width: 4),
          Text(
            "$rating",
            style: TextStyle(
              color: const Color(0xFFC2410C),
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (reviewCount != null) ...[
            Text(
              "($reviewCount)",
              style: const TextStyle(
                color: Color(0xFFF97316),
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
