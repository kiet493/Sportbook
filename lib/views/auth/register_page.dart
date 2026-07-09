import 'package:flutter/material.dart';

import 'widgets/widgets.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback onLogin;

  const RegisterPage({
    super.key,
    required this.onSuccess,
    required this.onLogin,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPwController = TextEditingController();

  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _agreed = false;
  bool _isLoading = false;
  bool _isSuccess = false;

  String? _fullNameError;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;
  String? _confirmPwError;
  String? _agreedError;

  int _passwordStrength = 0;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_calculatePasswordStrength);
  }

  void _calculatePasswordStrength() {
    final password = _passwordController.text;
    var strength = 0;

    if (password.isEmpty) {
      setState(() => _passwordStrength = 0);
      return;
    }

    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[^A-Za-z0-9]'))) strength++;

    setState(() => _passwordStrength = strength == 0 ? 1 : strength);
  }

  Future<void> _validateAndRegister() async {
    setState(() {
      _fullNameError = null;
      _emailError = null;
      _phoneError = null;
      _passwordError = null;
      _confirmPwError = null;
      _agreedError = null;
    });

    final name = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirmPw = _confirmPwController.text;
    var hasError = false;

    if (name.isEmpty) {
      _fullNameError = "Vui lòng nhập họ tên";
      hasError = true;
    }

    if (email.isEmpty) {
      _emailError = "Vui lòng nhập email";
      hasError = true;
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email)) {
      _emailError = "Email không hợp lệ";
      hasError = true;
    }

    if (phone.isEmpty) {
      _phoneError = "Vui lòng nhập số điện thoại";
      hasError = true;
    }

    if (password.isEmpty) {
      _passwordError = "Mật khẩu tối thiểu 6 ký tự";
      hasError = true;
    } else if (password.length < 6) {
      _passwordError = "Mật khẩu tối thiểu 6 ký tự";
      hasError = true;
    }

    if (password != confirmPw) {
      _confirmPwError = "Mật khẩu không khớp";
      hasError = true;
    }

    if (!_agreed) {
      _agreedError = "Vui lòng đồng ý điều khoản";
      hasError = true;
    }

    if (hasError) {
      setState(() {});
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1600));
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
    _passwordController.removeListener(_calculatePasswordStrength);
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPwController.dispose();
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
            AuthHeader(
              imageUrl:
                  "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&h=500&fit=crop&auto=format&q=80",
              heightFactor: 0.26,
              gradientColors: const [Colors.black26, Color(0xFFF8FAFC)],
              gradientStops: const [0.0, 1.0],
              onBack: widget.onLogin,
            ),
            RegisterForm(
              fullNameController: _fullNameController,
              emailController: _emailController,
              phoneController: _phoneController,
              passwordController: _passwordController,
              confirmPwController: _confirmPwController,
              fullNameError: _fullNameError,
              emailError: _emailError,
              phoneError: _phoneError,
              passwordError: _passwordError,
              confirmPwError: _confirmPwError,
              agreedError: _agreedError,
              showPassword: _showPassword,
              showConfirmPassword: _showConfirmPassword,
              agreed: _agreed,
              isLoading: _isLoading,
              isSuccess: _isSuccess,
              passwordStrength: _passwordStrength,
              onTogglePassword: () {
                setState(() => _showPassword = !_showPassword);
              },
              onToggleConfirmPassword: () {
                setState(() => _showConfirmPassword = !_showConfirmPassword);
              },
              onToggleAgreed: () {
                setState(() => _agreed = !_agreed);
              },
              onSubmit: _validateAndRegister,
              onLogin: widget.onLogin,
            ),
          ],
        ),
      ),
    );
  }
}
