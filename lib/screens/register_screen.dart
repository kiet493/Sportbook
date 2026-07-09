import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback onLogin;

  const RegisterScreen({
    Key? key,
    required this.onSuccess,
    required this.onLogin,
  }) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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
    int strength = 0;
    if (password.isEmpty) {
      setState(() {
        _passwordStrength = 0;
      });
      return;
    }

    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[^A-Za-z0-9]'))) strength++;

    setState(() {
      _passwordStrength = strength == 0 ? 1 : strength;
    });
  }

  Color _getStrengthColor() {
    switch (_passwordStrength) {
      case 1:
        return const Color(0xFFEF4444); // Weak - Red
      case 2:
        return const Color(0xFFF97316); // Medium - Orange
      case 3:
        return const Color(0xFFEAB308); // Good - Yellow
      case 4:
        return const Color(0xFF22C55E); // Strong - Green
      default:
        return Colors.transparent;
    }
  }

  String _getStrengthLabel() {
    switch (_passwordStrength) {
      case 1:
        return "Yếu";
      case 2:
        return "Trung bình";
      case 3:
        return "Khá";
      case 4:
        return "Mạnh";
      default:
        return "";
    }
  }

  void _validateAndRegister() async {
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

    bool hasError = false;

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

    // Process Mock Register
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 1600));

    setState(() {
      _isLoading = false;
      _isSuccess = true;
    });

    await Future.delayed(const Duration(milliseconds: 700));
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
            // Header Image with Back Button
            Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.26,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&h=500&fit=crop&auto=format&q=80",
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black26,
                          Color(0xFFF8FAFC),
                        ],
                        stops: [0.0, 1.0],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 48,
                  left: 16,
                  child: GestureDetector(
                    onTap: widget.onLogin,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.82),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.chevron_left,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Form Fields
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Tạo tài khoản",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Tham gia cùng hàng nghìn người chơi thể thao mỗi ngày.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Họ và tên
                  _buildTextField(
                    controller: _fullNameController,
                    label: "Họ và tên",
                    prefixIcon: Icons.account_circle_outlined,
                    errorText: _fullNameError,
                  ),
                  const SizedBox(height: 14),

                  // Địa chỉ email
                  _buildTextField(
                    controller: _emailController,
                    label: "Địa chỉ email",
                    prefixIcon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                    errorText: _emailError,
                  ),
                  const SizedBox(height: 14),

                  // Số điện thoại
                  _buildTextField(
                    controller: _phoneController,
                    label: "Số điện thoại",
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    errorText: _phoneError,
                  ),
                  const SizedBox(height: 14),

                  // Mật khẩu
                  _buildTextField(
                    controller: _passwordController,
                    label: "Mật khẩu",
                    prefixIcon: Icons.lock_outline,
                    obscureText: !_showPassword,
                    errorText: _passwordError,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: const Color(0xFF94A3B8),
                        size: 18,
                      ),
                      onPressed: () {
                        setState(() {
                          _showPassword = !_showPassword;
                        });
                      },
                    ),
                  ),

                  // Password strength meter
                  if (_passwordController.text.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: List.generate(
                                4,
                                (i) => Expanded(
                                  child: Container(
                                    height: 4,
                                    margin: const EdgeInsets.symmetric(horizontal: 2.0),
                                    decoration: BoxDecoration(
                                      color: i < _passwordStrength
                                          ? _getStrengthColor()
                                          : const Color(0xFFE2E8F0),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 70,
                            child: Text(
                              _getStrengthLabel(),
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: _getStrengthColor(),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),

                  // Xác nhận mật khẩu
                  _buildTextField(
                    controller: _confirmPwController,
                    label: "Xác nhận mật khẩu",
                    prefixIcon: Icons.lock_outline,
                    obscureText: !_showConfirmPassword,
                    errorText: _confirmPwError,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showConfirmPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: const Color(0xFF94A3B8),
                        size: 18,
                      ),
                      onPressed: () {
                        setState(() {
                          _showConfirmPassword = !_showConfirmPassword;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // T&C Checkbox
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _agreed = !_agreed;
                      });
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          margin: const EdgeInsets.only(top: 2),
                          decoration: BoxDecoration(
                            color: _agreed
                                ? const Color(0xFF2563EB)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: _agreed
                                  ? const Color(0xFF2563EB)
                                  : const Color(0xFFCBD5E1),
                              width: 1.5,
                            ),
                          ),
                          child: _agreed
                              ? const Icon(
                                  Icons.check,
                                  size: 12,
                                  color: Colors.white,
                                )
                              : null,
                        ),
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
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: GestureDetector(
                                    onTap: () {},
                                    child: const Text(
                                      'Điều khoản',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2563EB),
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ),
                                const TextSpan(text: ' và '),
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: GestureDetector(
                                    onTap: () {},
                                    child: const Text(
                                      'Chính sách bảo mật',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2563EB),
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_agreedError != null) ...[
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.only(left: 30.0),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Color(0xFFEF4444),
                            size: 12,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _agreedError!,
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
                  const SizedBox(height: 20),

                  // Register Button
                  ElevatedButton(
                    onPressed: (_isLoading || _isSuccess) ? null : _validateAndRegister,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: _isSuccess
                          ? const Color(0xFF22C55E)
                          : const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: _isSuccess
                          ? const Color(0xFF22C55E)
                          : const Color(0xFF2563EB).withOpacity(0.6),
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : _isSuccess
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    "Tạo tài khoản thành công!",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              )
                            : const Text(
                                "Tạo tài khoản",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                  ),

                  // Divider
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Row(
                      children: [
                        const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                            "hoặc",
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF94A3B8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                      ],
                    ),
                  ),

                  // Google button
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0F172A),
                      minimumSize: const Size(double.infinity, 56),
                      side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(
                          "https://img.icons8.com/color/48/000000/google-logo.png",
                          height: 18,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Đăng ký với Google",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Footer login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Đã có tài khoản? ",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      GestureDetector(
                        onTap: widget.onLogin,
                        child: const Text(
                          "Đăng nhập",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData prefixIcon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? errorText,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: errorText != null
                  ? const Color(0xFFEF4444)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              floatingLabelStyle: const TextStyle(
                color: Color(0xFF2563EB),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              prefixIcon: Icon(
                prefixIcon,
                color: const Color(0xFF94A3B8),
                size: 18,
              ),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Color(0xFFEF4444),
                  size: 12,
                ),
                const SizedBox(width: 6),
                Text(
                  errorText,
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
}
