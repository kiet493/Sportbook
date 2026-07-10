import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// Standardised text field used inside [UserFormDialog].
///
/// Keeps the same filled + rounded visual language as the auth
/// forms so the admin CRUD modal feels consistent with the rest of
/// the app.
class FormTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const FormTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.surfaceMuted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }
}

/// Standardised dropdown used inside [UserFormDialog].
class FormDropdown<T> extends StatelessWidget {
  final String label;
  final IconData icon;
  final T value;
  final List<T> options;
  final String Function(T) labelOf;
  final ValueChanged<T> onChanged;

  const FormDropdown({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.options,
    required this.labelOf,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.surfaceMuted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      items: options
          .map(
            (o) => DropdownMenuItem<T>(
              value: o,
              child: Text(labelOf(o)),
            ),
          )
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}

/// Bottom action row for [UserFormDialog]. Cancel + primary submit,
/// with an inline spinner while the save is in flight.
class FormActions extends StatelessWidget {
  final bool saving;
  final bool isEdit;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  const FormActions({
    super.key,
    required this.saving,
    required this.isEdit,
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: saving ? null : onCancel,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text('Hủy'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: saving ? null : onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size(0, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(isEdit ? 'Lưu' : 'Tạo'),
          ),
        ),
      ],
    );
  }
}