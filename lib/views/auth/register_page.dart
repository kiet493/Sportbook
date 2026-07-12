import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/auth_validators.dart';
import '../../providers/registration_providers.dart';
import 'widgets/widgets.dart';

class RegisterPage extends ConsumerStatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback onLogin;

  const RegisterPage({
    super.key,
    required this.onSuccess,
    required this.onLogin,
  });

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
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
  String? _formError;

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

    if (password.length >= 6) strength++;
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
      _formError = null;
    });

    final name = _fullNameController.text.trim().replaceAll(
      RegExp(r'\s+'),
      ' ',
    );
    final email = AuthValidators.normaliseEmail(_emailController.text);
    final phone = AuthValidators.normalisePhone(_phoneController.text);
    final password = _passwordController.text;
    final confirmPw = _confirmPwController.text;
    _fullNameError = AuthValidators.fullName(name);
    _emailError = AuthValidators.email(email);
    _phoneError = AuthValidators.phone(phone);
    _passwordError = AuthValidators.registrationPassword(password);
    _confirmPwError = AuthValidators.confirmPassword(password, confirmPw);
    var hasError =
        _fullNameError != null ||
        _emailError != null ||
        _phoneError != null ||
        _passwordError != null ||
        _confirmPwError != null;

    if (!_agreed) {
      _agreedError = "Vui lòng đồng ý điều khoản";
      hasError = true;
    }

    if (hasError) {
      setState(() {});
      return;
    }

    setState(() => _isLoading = true);
    final result = await ref
        .read(registrationProvider.notifier)
        .submit(fullName: name, email: email, phone: phone, password: password);
    if (!mounted) return;

    if (!result.success) {
      setState(() {
        _isLoading = false;
        _applyRegistrationError(result);
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

  void _applyRegistrationError(RegistrationResult result) {
    switch (result.fieldError) {
      case 'fullName':
        _fullNameError = result.message;
        return;
      case 'email':
        _emailError = result.message;
        return;
      case 'phone':
        _phoneError = result.message;
        return;
      case 'password':
        _passwordError = result.message;
        return;
      default:
        _formError = result.message ?? 'Không thể tạo tài khoản';
    }
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
              formError: _formError,
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
