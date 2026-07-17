import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/section_card.dart';
import '../../../models/booking_model.dart';

/// Pure function: build the [TimelineStep] list shown above the info
/// card. Kept in the views layer (not the model) because the strings
/// are UI copy and the times are presentation-only.
List<TimelineStep> buildBookingTimeline({
  required String status,
  String bookedAt = 'Đã ghi nhận',
}) {
  return [
    TimelineStep(label: 'Đặt sân thành công', time: bookedAt, done: true),
    TimelineStep(
      label: status == BookingStatus.cancelled
          ? 'Lịch đã được hủy'
          : 'Sân đã xác nhận',
      time: status == BookingStatus.cancelled ? 'Đã hủy' : 'Đã xác nhận',
      done: status != BookingStatus.cancelled,
    ),
    TimelineStep(
      label: 'Hoàn thành',
      time: status == BookingStatus.completed ? 'Đã hoàn thành' : '--',
      done: status == BookingStatus.completed,
    ),
  ];
}

/// Vertical stepper showing booking progress (booked → paid → confirmed → done).
///
/// Renders a connected dot for each [TimelineStep]. Future steps are muted;
/// completed steps are brand-blue with a check icon.
class BookingDetailTimeline extends StatelessWidget {
  final List<TimelineStep> steps;

  const BookingDetailTimeline({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Trạng thái đặt sân',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: List.generate(steps.length, (index) {
              final step = steps[index];
              final isLast = index == steps.length - 1;
              final nextDone =
                  !isLast && steps[index + 1].done && step.done;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      _StepDot(done: step.done),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 32,
                          color: nextDone
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: step.done
                                ? AppColors.textPrimary
                                : AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          step.time,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final bool done;
  const _StepDot({required this.done});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done ? AppColors.primary : AppColors.border,
      ),
      alignment: Alignment.center,
      child: done
          ? const Icon(Icons.check, size: 12, color: Colors.white)
          : Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.textMuted,
                shape: BoxShape.circle,
              ),
            ),
    );
  }
}
