import 'package:flutter/material.dart';

class BookingHistoryTabs extends StatelessWidget {
  final String activeTab;
  final ValueChanged<String> onChanged;
  final int Function(String status) countByStatus;

  const BookingHistoryTabs({
    super.key,
    required this.activeTab,
    required this.onChanged,
    required this.countByStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _BookingHistoryTabButton(
            status: "upcoming",
            label: "Sắp tới",
            isSelected: activeTab == "upcoming",
            count: countByStatus("upcoming"),
            onTap: onChanged,
          ),
          _BookingHistoryTabButton(
            status: "completed",
            label: "Hoàn thành",
            isSelected: activeTab == "completed",
            count: countByStatus("completed"),
            onTap: onChanged,
          ),
          _BookingHistoryTabButton(
            status: "cancelled",
            label: "Đã hủy",
            isSelected: activeTab == "cancelled",
            count: countByStatus("cancelled"),
            onTap: onChanged,
          ),
        ],
      ),
    );
  }
}

class _BookingHistoryTabButton extends StatelessWidget {
  final String status;
  final String label;
  final bool isSelected;
  final int count;
  final ValueChanged<String> onTap;

  const _BookingHistoryTabButton({
    required this.status,
    required this.label,
    required this.isSelected,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(status),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? const Color(0xFF0F172A)
                      : const Color(0xFF64748B),
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF2563EB)
                        : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "$count",
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
