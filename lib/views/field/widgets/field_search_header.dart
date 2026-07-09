import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class FieldSearchHeader extends StatelessWidget {
  final TextEditingController searchController;
  final FocusNode focusNode;
  final String query;
  final bool showFilter;
  final List<String> sports;
  final String selectedSport;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClearSearch;
  final VoidCallback onToggleFilter;
  final ValueChanged<String> onSportSelected;
  final VoidCallback onBack;

  const FieldSearchHeader({
    super.key,
    required this.searchController,
    required this.focusNode,
    required this.query,
    required this.showFilter,
    required this.sports,
    required this.selectedSport,
    required this.onQueryChanged,
    required this.onClearSearch,
    required this.onToggleFilter,
    required this.onSportSelected,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1.0),
        ),
      ),
      child: Column(
        children: [
          _SearchInputRow(
            searchController: searchController,
            focusNode: focusNode,
            query: query,
            showFilter: showFilter,
            onQueryChanged: onQueryChanged,
            onClearSearch: onClearSearch,
            onToggleFilter: onToggleFilter,
            onBack: onBack,
          ),
          const SizedBox(height: 8),
          _SportChips(
            sports: sports,
            selectedSport: selectedSport,
            onSportSelected: onSportSelected,
          ),
        ],
      ),
    );
  }
}

class _SearchInputRow extends StatelessWidget {
  final TextEditingController searchController;
  final FocusNode focusNode;
  final String query;
  final bool showFilter;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClearSearch;
  final VoidCallback onToggleFilter;
  final VoidCallback onBack;

  const _SearchInputRow({
    required this.searchController,
    required this.focusNode,
    required this.query,
    required this.showFilter,
    required this.onQueryChanged,
    required this.onClearSearch,
    required this.onToggleFilter,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _BackButton(onTap: onBack),
        const SizedBox(width: 8),
        Expanded(
          child: _SearchInputBox(
            searchController: searchController,
            focusNode: focusNode,
            query: query,
            onQueryChanged: onQueryChanged,
            onClearSearch: onClearSearch,
          ),
        ),
        const SizedBox(width: 8),
        _FilterButton(
          showFilter: showFilter,
          onTap: onToggleFilter,
        ),
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.chevron_left, color: AppColors.textPrimary),
      ),
    );
  }
}

class _SearchInputBox extends StatelessWidget {
  final TextEditingController searchController;
  final FocusNode focusNode;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClearSearch;

  const _SearchInputBox({
    required this.searchController,
    required this.focusNode,
    required this.query,
    required this.onQueryChanged,
    required this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.textMuted, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: searchController,
              focusNode: focusNode,
              onChanged: onQueryChanged,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              decoration: const InputDecoration(
                hintText: "Tìm sân, môn thể thao...",
                hintStyle: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (query.isNotEmpty)
            GestureDetector(
              onTap: onClearSearch,
              child: const Icon(Icons.close, color: AppColors.textMuted, size: 16),
            ),
          const SizedBox(width: 8),
          const Icon(Icons.mic_none, color: AppColors.textMuted, size: 18),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final bool showFilter;
  final VoidCallback onTap;

  const _FilterButton({required this.showFilter, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: showFilter ? AppColors.primary : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: showFilter ? AppColors.primary : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Icon(
          Icons.filter_list,
          color: showFilter ? Colors.white : AppColors.textSecondary,
          size: 18,
        ),
      ),
    );
  }
}

class _SportChips extends StatelessWidget {
  final List<String> sports;
  final String selectedSport;
  final ValueChanged<String> onSportSelected;

  const _SportChips({
    required this.sports,
    required this.selectedSport,
    required this.onSportSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: sports.length,
        itemBuilder: (context, index) {
          final sport = sports[index];
          final isSelected = selectedSport == sport;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ChoiceChip(
              label: Text(
                sport,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) onSportSelected(sport);
              },
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surface,
              pressElevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 1.0,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
