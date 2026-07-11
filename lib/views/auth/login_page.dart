import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/auth_validators.dart';
import '../../providers/registration_providers.dart';
import 'widgets/widgets.dart';

class LoginPage extends ConsumerStatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback onRegister;

  const LoginPage({
    super.key,
    required this.onSuccess,
    required this.onRegister,
  });

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _showPassword = false;
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _isSuccess = false;

  String? _emailError;
  String? _passwordError;
  String? _formError;

  Future<void> _validateAndSubmit() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
      _formError = null;
    });

    final email = AuthValidators.normaliseEmail(_emailController.text);
    final password = _passwordController.text;
    _emailError = AuthValidators.email(email);
    _passwordError = AuthValidators.loginPassword(password);
    final hasError = _emailError != null || _passwordError != null;

    if (hasError) {
      setState(() {});
      return;
    }

    setState(() => _isLoading = true);
    final error = await ref
        .read(loginProvider.notifier)
        .login(email: email, password: password);
    if (!mounted) return;

    if (error != null) {
      setState(() {
        _isLoading = false;
        _formError = error;
      });
      return;
    }

    setState(() {
      _isLoading = false;
      _isSuccess = true;
    });

    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    widget.onSuccess();
  }

  Future<void> _forgotPassword() async {
    final email = AuthValidators.normaliseEmail(_emailController.text);
    final validationError = AuthValidators.email(email);
    if (validationError != null) {
      setState(() => _emailError = validationError);
      return;
    }

    final error = await ref
        .read(loginProvider.notifier)
        .sendPasswordReset(email);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'Đã gửi liên kết đặt lại mật khẩu đến $email'),
        backgroundColor: error == null ? const Color(0xFF16A34A) : null,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthHeader(
              imageUrl:
                  "https://images.unsplash.com/photo-1517649763962-0c623066013b?w=800&h=600&fit=crop&auto=format&q=80",
              heightFactor: 0.38,
              gradientColors: [
                Colors.black26,
                Colors.transparent,
                Color(0xFFF8FAFC),
              ],
              gradientStops: [0.0, 0.6, 1.0],
              showBrandBadge: true,
            ),
            LoginForm(
              emailController: _emailController,
              passwordController: _passwordController,
              emailError: _emailError,
              passwordError: _passwordError,
              formError: _formError,
              showPassword: _showPassword,
              rememberMe: _rememberMe,
              isLoading: _isLoading,
              isSuccess: _isSuccess,
              onTogglePassword: () {
                setState(() => _showPassword = !_showPassword);
              },
              onToggleRemember: () {
                setState(() => _rememberMe = !_rememberMe);
              },
              onSubmit: _validateAndSubmit,
              onForgotPassword: _forgotPassword,
              onRegister: widget.onRegister,
            ),
          ],
        ),
      ),
    );
  }
}
