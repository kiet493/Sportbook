import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/auth_validators.dart';
import '../../providers/registration_providers.dart';
import 'widgets/auth_submit_button.dart';
import 'widgets/auth_text_field.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  final VoidCallback onBack;

  const ForgotPasswordPage({super.key, required this.onBack});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  String? _emailError;
  String? _message;
  bool _loading = false;
  bool _success = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = AuthValidators.normaliseEmail(_emailController.text);
    final validation = AuthValidators.email(email);
    setState(() {
      _emailError = validation;
      _message = null;
    });
    if (validation != null) return;

    setState(() => _loading = true);
    final error = await ref
        .read(loginProvider.notifier)
        .sendPasswordReset(email);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _success = error == null;
      _message = error ?? 'Đã gửi liên kết đặt lại mật khẩu đến $email.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: widget.onBack,
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        title: const Text('Quên mật khẩu'),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 24),
            const Icon(
              Icons.mark_email_read_outlined,
              size: 72,
              color: Color(0xFF2563EB),
            ),
            const SizedBox(height: 24),
            const Text(
              'Khôi phục tài khoản',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text(
              'Nhập email đã đăng ký. Firebase sẽ gửi liên kết để bạn tạo mật khẩu mới.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF64748B), height: 1.5),
            ),
            const SizedBox(height: 30),
            AuthTextField(
              controller: _emailController,
              label: 'Địa chỉ email',
              prefixIcon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
              errorText: _emailError,
            ),
            if (_message != null) ...[
              const SizedBox(height: 14),
              Text(
                _message!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _success
                      ? const Color(0xFF16A34A)
                      : const Color(0xFFDC2626),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 24),
            AuthSubmitButton(
              label: 'Gửi liên kết',
              successLabel: 'Đã gửi email!',
              isLoading: _loading,
              isSuccess: _success,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
