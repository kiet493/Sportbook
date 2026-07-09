import 'package:flutter/material.dart';

class BookingStatusBadge extends StatelessWidget {
  final String status;
  final EdgeInsets padding;
  final double fontSize;

  const BookingStatusBadge({
    super.key,
    required this.status,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    this.fontSize = 9,
  });

  @override
  Widget build(BuildContext context) {
    final style = _statusStyle(status);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: style.backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        style.label,
        style: TextStyle(
          color: style.textColor,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

_BookingStatusStyle _statusStyle(String status) {
  switch (status) {
    case "upcoming":
      return const _BookingStatusStyle(
        label: "Sắp tới",
        backgroundColor: Color(0xFFDBEAFE),
        textColor: Color(0xFF1D4ED8),
      );
    case "completed":
      return const _BookingStatusStyle(
        label: "Hoàn thành",
        backgroundColor: Color(0xFFDCFCE7),
        textColor: Color(0xFF15803D),
      );
    case "cancelled":
      return const _BookingStatusStyle(
        label: "Đã hủy",
        backgroundColor: Color(0xFFFEE2E2),
        textColor: Color(0xFFB91C1C),
      );
    default:
      return const _BookingStatusStyle(
        label: "Sắp tới",
        backgroundColor: Color(0xFFDBEAFE),
        textColor: Color(0xFF1D4ED8),
      );
  }
}

class _BookingStatusStyle {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const _BookingStatusStyle({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });
}
