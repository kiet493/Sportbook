import 'package:flutter/material.dart';

class FieldSportsTags extends StatelessWidget {
  final List<String> sports;

  const FieldSportsTags({
    super.key,
    required this.sports,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: sports.map((s) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFDBEAFE),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            s,
            style: const TextStyle(
              color: Color(0xFF1D4ED8),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }).toList(),
    );
  }
}
