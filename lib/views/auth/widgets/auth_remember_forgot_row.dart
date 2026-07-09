import 'package:flutter/material.dart';

class AuthRememberForgotRow extends StatelessWidget {
  final bool rememberMe;
  final VoidCallback onToggleRemember;
  final VoidCallback onForgotPassword;

  const AuthRememberForgotRow({
    super.key,
    required this.rememberMe,
    required this.onToggleRemember,
    required this.onForgotPassword,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: onToggleRemember,
          child: Row(
            children: [
              _CheckBoxMark(checked: rememberMe),
              const SizedBox(width: 8),
              const Text(
                "Ghi nhớ đăng nhập",
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: onForgotPassword,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            "Quên mật khẩu?",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2563EB),
            ),
          ),
        ),
      ],
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
