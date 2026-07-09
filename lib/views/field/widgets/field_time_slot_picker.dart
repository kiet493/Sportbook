import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/venue.dart';

class FieldTimeSlotPicker extends StatefulWidget {
  final List<String> dates;
  final List<TimeSlot> timeSlots;
  final String selectedDate;
  final String? selectedSlot;
  final ValueChanged<String> onDateSelected;
  final ValueChanged<String?> onSlotSelected;

  const FieldTimeSlotPicker({
    super.key,
    required this.dates,
    required this.timeSlots,
    required this.selectedDate,
    this.selectedSlot,
    required this.onDateSelected,
    required this.onSlotSelected,
  });

  @override
  State<FieldTimeSlotPicker> createState() => _FieldTimeSlotPickerState();
}

class _FieldTimeSlotPickerState extends State<FieldTimeSlotPicker> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DateChips(
          dates: widget.dates,
          selectedDate: widget.selectedDate,
          onDateSelected: widget.onDateSelected,
        ),
        const SizedBox(height: 12),
        _TimeSlotsGrid(
          timeSlots: widget.timeSlots,
          selectedSlot: widget.selectedSlot,
          onSlotSelected: widget.onSlotSelected,
        ),
      ],
    );
  }
}

class _DateChips extends StatelessWidget {
  final List<String> dates;
  final String selectedDate;
  final ValueChanged<String> onDateSelected;

  const _DateChips({
    required this.dates,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final d = dates[index];
          final isSelected = selectedDate == d;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ChoiceChip(
              label: Text(
                d,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) onDateSelected(d);
              },
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surface,
              pressElevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TimeSlotsGrid extends StatelessWidget {
  final List<TimeSlot> timeSlots;
  final String? selectedSlot;
  final ValueChanged<String?> onSlotSelected;

  const _TimeSlotsGrid({
    required this.timeSlots,
    this.selectedSlot,
    required this.onSlotSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        childAspectRatio: 2.1,
      ),
      itemCount: timeSlots.length,
      itemBuilder: (context, index) {
        final slot = timeSlots[index];
        final isSelected = selectedSlot == slot.time;

        return InkWell(
          onTap: slot.available ? () => onSlotSelected(slot.time) : null,
          child: AnimatedContainer(
            alignment: Alignment.center,
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: !slot.available
                  ? AppColors.surfaceMuted
                  : isSelected
                      ? AppColors.primary
                      : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: !slot.available
                    ? AppColors.border
                    : isSelected
                        ? AppColors.primary
                        : AppColors.border,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.28),
                        blurRadius: 10,
                      ),
                    ]
                  : null,
            ),
            child: Text(
              slot.time,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: !slot.available
                    ? const Color(0xFFCBD5E1)
                    : isSelected
                        ? Colors.white
                        : AppColors.textPrimary,
              ),
            ),
          ),
        );
      },
    );
  }
}
