import 'package:flutter/material.dart';

class OnboardingPage extends StatelessWidget {
  final VoidCallback onComplete;
  final VoidCallback onSignIn;
  const OnboardingPage({super.key, required this.onComplete, required this.onSignIn});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Spacer(),
          const Icon(Icons.sports_tennis, size: 72, color: Color(0xFF2563EB)),
          const SizedBox(height: 24),
          const Text('SportBook', textAlign: TextAlign.center, style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          const Text('Tìm sân trống và đặt lịch trực tiếp với dữ liệu thời gian thực.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF64748B), height: 1.5)),
          const Spacer(),
          FilledButton(onPressed: onComplete, style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)), child: const Text('Bắt đầu')),
          TextButton(onPressed: onSignIn, child: const Text('Đã có tài khoản')),
        ]),
      ),
    ),
  );
}
