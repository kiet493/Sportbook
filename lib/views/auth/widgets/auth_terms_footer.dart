import 'package:flutter/material.dart';

class AuthTermsFooter extends StatelessWidget {
  const AuthTermsFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text.rich(
        TextSpan(
          text: 'Bằng cách tiếp tục, bạn đồng ý với ',
          style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
          children: [
            _linkSpan('Điều khoản'),
            const TextSpan(text: ' và '),
            _linkSpan('Chính sách bảo mật'),
          ],
        ),
        textAlign: TextAlign.center,
      ),
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
            fontSize: 11,
            color: Color(0xFF94A3B8),
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}
