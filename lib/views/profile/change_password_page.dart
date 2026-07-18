import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/auth_validators.dart';
import '../../providers/registration_providers.dart';

class ChangePasswordPage extends ConsumerStatefulWidget {
  final VoidCallback onBack;

  const ChangePasswordPage({super.key, required this.onBack});

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final current = _currentController.text;
    final next = _newController.text;
    final confirm = _confirmController.text;
    final error = current.isEmpty
        ? 'Vui lòng nhập mật khẩu hiện tại.'
        : AuthValidators.registrationPassword(next) ??
              AuthValidators.confirmPassword(next, confirm);
    setState(() => _error = error);
    if (error != null) return;

    final result = await ref
        .read(profileProvider.notifier)
        .changePassword(currentPassword: current, newPassword: next);
    if (!mounted) return;
    if (result != null) {
      setState(() => _error = result);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đổi mật khẩu thành công.'),
        backgroundColor: Color(0xFF16A34A),
      ),
    );
    widget.onBack();
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(profileProvider).isLoading;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Đổi mật khẩu'),
        leading: IconButton(
          onPressed: widget.onBack,
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _PasswordField(
            controller: _currentController,
            label: 'Mật khẩu hiện tại',
            obscure: _obscure,
          ),
          const SizedBox(height: 16),
          _PasswordField(
            controller: _newController,
            label: 'Mật khẩu mới',
            obscure: _obscure,
          ),
          const SizedBox(height: 16),
          _PasswordField(
            controller: _confirmController,
            label: 'Xác nhận mật khẩu mới',
            obscure: _obscure,
            suffix: IconButton(
              onPressed: () => setState(() => _obscure = !_obscure),
              icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Color(0xFFDC2626))),
          ],
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: loading ? null : _save,
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
            ),
            icon: loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.lock_reset),
            label: const Text('Cập nhật mật khẩu'),
          ),
        ],
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscure;
  final Widget? suffix;

  const _PasswordField({
    required this.controller,
    required this.label,
    required this.obscure,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
