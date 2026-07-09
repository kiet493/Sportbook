import 'package:flutter/material.dart';

class AuthTermsCheckbox extends StatelessWidget {
  final bool agreed;
  final String? errorText;
  final VoidCallback onToggle;

  const AuthTermsCheckbox({
    super.key,
    required this.agreed,
    this.errorText,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onToggle,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CheckBoxMark(checked: agreed),
              const SizedBox(width: 10),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: 'Tôi đồng ý với ',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                      height: 1.4,
                    ),
                    children: [
                      _linkSpan('Điều khoản'),
                      const TextSpan(text: ' và '),
                      _linkSpan('Chính sách bảo mật'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 30),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Color(0xFFEF4444),
                  size: 12,
                ),
                const SizedBox(width: 6),
                Text(
                  errorText!,
                  style: const TextStyle(
                    color: Color(0xFFEF4444),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  static WidgetSpan _linkSpan(String label) {
    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: GestureDetector(
        onTap: () {},
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2563EB),
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}

class _CheckBoxMark extends StatelessWidget {
  final bool checked;

  const _CheckBoxMark({required this.checked});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      margin: const EdgeInsets.only(top: 2),
      decoration: BoxDecoration(
        color: checked ? const Color(0xFF2563EB) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: checked ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1),
          width: 1.5,
        ),
      ),
      child: checked
          ? const Icon(Icons.check, size: 12, color: Colors.white)
          : null,
    );
  }
}
