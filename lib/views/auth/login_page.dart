import 'package:flutter/material.dart';

import 'widgets/widgets.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback onRegister;

  const LoginPage({
    super.key,
    required this.onSuccess,
    required this.onRegister,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _showPassword = false;
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _isSuccess = false;

  String? _emailError;
  String? _passwordError;

  Future<void> _validateAndSubmit() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    var hasError = false;

    if (email.isEmpty) {
      _emailError = "Vui lòng nhập email";
      hasError = true;
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email)) {
      _emailError = "Email không hợp lệ";
      hasError = true;
    }

    if (password.isEmpty) {
      _passwordError = "Vui lòng nhập mật khẩu";
      hasError = true;
    } else if (password.length < 6) {
      _passwordError = "Mật khẩu tối thiểu 6 ký tự";
      hasError = true;
    }

    if (hasError) {
      setState(() {});
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _isSuccess = true;
    });

    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    widget.onSuccess();
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
              onRegister: widget.onRegister,
            ),
          ],
        ),
      ),
    );
  }
}
