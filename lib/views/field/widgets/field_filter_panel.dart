import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class FieldFilterPanel extends StatelessWidget {
  final List<String> sorts;
  final String selectedSort;
  final ValueChanged<String> onSortSelected;
  final int? maxPrice;
  final double? minRating;
  final bool onlyAvailable;
  final ValueChanged<int?> onMaxPriceChanged;
  final ValueChanged<double?> onMinRatingChanged;
  final ValueChanged<bool> onAvailabilityChanged;
  final VoidCallback onReset, onApply;
  const FieldFilterPanel({super.key, required this.sorts, required this.selectedSort, required this.onSortSelected, required this.maxPrice, required this.minRating, required this.onlyAvailable, required this.onMaxPriceChanged, required this.onMinRatingChanged, required this.onAvailabilityChanged, required this.onReset, required this.onApply});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: const BoxDecoration(color: AppColors.surface, border: Border(bottom: BorderSide(color: AppColors.border))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const Text('Sắp xếp theo', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Wrap(spacing: 6, runSpacing: 6, children: sorts.map((item) => _chip(item, selectedSort == item, () => onSortSelected(item))).toList()),
      const SizedBox(height: 14),
      const Text('Mức giá tối đa', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Wrap(spacing: 6, children: [_chip('Tất cả', maxPrice == null, () => onMaxPriceChanged(null)), _chip('≤ 150.000đ', maxPrice == 150000, () => onMaxPriceChanged(150000)), _chip('≤ 200.000đ', maxPrice == 200000, () => onMaxPriceChanged(200000)), _chip('≤ 300.000đ', maxPrice == 300000, () => onMaxPriceChanged(300000))]),
      const SizedBox(height: 14),
      const Text('Đánh giá', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Wrap(spacing: 6, children: [_chip('Tất cả', minRating == null, () => onMinRatingChanged(null)), _chip('Từ 4.0 ★', minRating == 4, () => onMinRatingChanged(4)), _chip('Từ 4.5 ★', minRating == 4.5, () => onMinRatingChanged(4.5))]),
      SwitchListTile.adaptive(contentPadding: EdgeInsets.zero, title: const Text('Chỉ sân đang mở', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)), value: onlyAvailable, onChanged: onAvailabilityChanged),
      Row(children: [TextButton(onPressed: onReset, child: const Text('Đặt lại')), const SizedBox(width: 8), Expanded(child: ElevatedButton(onPressed: onApply, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white), child: const Text('Áp dụng bộ lọc')))])
    ]),
  );

  Widget _chip(String label, bool selected, VoidCallback onTap) => ChoiceChip(label: Text(label, style: TextStyle(fontSize: 11, color: selected ? Colors.white : AppColors.textSecondary)), selected: selected, onSelected: (_) => onTap(), selectedColor: AppColors.primary, backgroundColor: AppColors.surfaceMuted);
}
