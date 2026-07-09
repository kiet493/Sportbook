import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/booking_model.dart';

/// Pure function: build the [TimelineStep] list shown above the info
/// card. Kept in the views layer (not the model) because the strings
/// are UI copy and the times are presentation-only.
List<TimelineStep> buildBookingTimeline({
  required String status,
  String bookedAt = '10:23 AM',
  String paidAt = '10:24 AM',
  String confirmedAt = '10:25 AM',
}) {
  return [
    TimelineStep(label: 'Đặt sân thành công', time: bookedAt, done: true),
    TimelineStep(label: 'Thanh toán xác nhận', time: paidAt, done: true),
    TimelineStep(
      label: 'Sân đã xác nhận',
      time: confirmedAt,
      done: status != BookingStatus.cancelled,
    ),
    TimelineStep(
      label: 'Hoàn thành',
      time: status == BookingStatus.completed ? 'Đã hoàn thành' : '--',
      done: status == BookingStatus.completed,
    ),
  ];
}

/// AppBar leading button. Centralized so every page uses the same
/// icon + color combo without redefining the hex values.
class BackChevronButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const BackChevronButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.chevron_left, color: AppColors.textPrimary),
      onPressed: onPressed ?? () => Navigator.of(context).maybePop(),
    );
  }
}
