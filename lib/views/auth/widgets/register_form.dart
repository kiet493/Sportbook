import 'package:flutter/material.dart';

import 'auth_divider.dart';
import 'auth_footer_link.dart';
import 'auth_intro.dart';
import 'auth_social_button.dart';
import 'auth_submit_button.dart';
import 'auth_terms_checkbox.dart';
import 'auth_text_field.dart';
import 'password_strength_meter.dart';

class RegisterForm extends StatelessWidget {
  final TextEditingController fullNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final TextEditingController confirmPwController;
  final String? fullNameError;
  final String? emailError;
  final String? phoneError;
  final String? passwordError;
  final String? confirmPwError;
  final String? agreedError;
  final bool showPassword;
  final bool showConfirmPassword;
  final bool agreed;
  final bool isLoading;
  final bool isSuccess;
  final int passwordStrength;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;
  final VoidCallback onToggleAgreed;
  final VoidCallback onSubmit;
  final VoidCallback onLogin;

  const RegisterForm({
    super.key,
    required this.fullNameController,
    required this.emailController,
    required this.phoneController,
    required this.passwordController,
    required this.confirmPwController,
    this.fullNameError,
    this.emailError,
    this.phoneError,
    this.passwordError,
    this.confirmPwError,
    this.agreedError,
    required this.showPassword,
    required this.showConfirmPassword,
    required this.agreed,
    required this.isLoading,
    required this.isSuccess,
    required this.passwordStrength,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
    required this.onToggleAgreed,
    required this.onSubmit,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthIntro(
            title: "Tạo tài khoản",
            subtitle: "Tham gia cùng hàng nghìn người chơi thể thao mỗi ngày.",
          ),
          const SizedBox(height: 20),
          AuthTextField(
            controller: fullNameController,
            label: "Họ và tên",
            prefixIcon: Icons.account_circle_outlined,
            errorText: fullNameError,
          ),
          const SizedBox(height: 14),
          AuthTextField(
            controller: emailController,
            label: "Địa chỉ email",
            prefixIcon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
            errorText: emailError,
          ),
          const SizedBox(height: 14),
          AuthTextField(
            controller: phoneController,
            label: "Số điện thoại",
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            errorText: phoneError,
          ),
          const SizedBox(height: 14),
          AuthTextField(
            controller: passwordController,
            label: "Mật khẩu",
            prefixIcon: Icons.lock_outline,
            obscureText: !showPassword,
            errorText: passwordError,
            suffixIcon: IconButton(
              icon: Icon(
                showPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: const Color(0xFF94A3B8),
                size: 18,
              ),
              onPressed: onTogglePassword,
            ),
          ),
          if (passwordController.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            PasswordStrengthMeter(strength: passwordStrength),
          ],
          const SizedBox(height: 14),
          AuthTextField(
            controller: confirmPwController,
            label: "Xác nhận mật khẩu",
            prefixIcon: Icons.lock_outline,
            obscureText: !showConfirmPassword,
            errorText: confirmPwError,
            suffixIcon: IconButton(
              icon: Icon(
                showConfirmPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: const Color(0xFF94A3B8),
                size: 18,
              ),
              onPressed: onToggleConfirmPassword,
            ),
          ),
          const SizedBox(height: 16),
          AuthTermsCheckbox(
            agreed: agreed,
            errorText: agreedError,
            onToggle: onToggleAgreed,
          ),
          const SizedBox(height: 20),
          AuthSubmitButton(
            label: "Tạo tài khoản",
            successLabel: "Tạo tài khoản thành công!",
            isLoading: isLoading,
            isSuccess: isSuccess,
            onPressed: onSubmit,
          ),
          const AuthDivider(),
          AuthSocialButton(label: "Đăng ký với Google", onPressed: () {}),
          const SizedBox(height: 24),
          AuthFooterLink(
            prompt: "Đã có tài khoản? ",
            actionLabel: "Đăng nhập",
            onTap: onLogin,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
