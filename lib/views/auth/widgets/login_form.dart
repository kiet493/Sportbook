import 'package:flutter/material.dart';

import 'auth_divider.dart';
import 'auth_footer_link.dart';
import 'auth_form_error.dart';
import 'auth_intro.dart';
import 'auth_remember_forgot_row.dart';
import 'auth_social_button.dart';
import 'auth_submit_button.dart';
import 'auth_terms_footer.dart';
import 'auth_text_field.dart';

class LoginForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final String? emailError;
  final String? passwordError;
  final String? formError;
  final bool showPassword;
  final bool rememberMe;
  final bool isLoading;
  final bool isSuccess;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleRemember;
  final VoidCallback onSubmit;
  final VoidCallback onForgotPassword;
  final VoidCallback onRegister;

  const LoginForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    this.emailError,
    this.passwordError,
    this.formError,
    required this.showPassword,
    required this.rememberMe,
    required this.isLoading,
    required this.isSuccess,
    required this.onTogglePassword,
    required this.onToggleRemember,
    required this.onSubmit,
    required this.onForgotPassword,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthIntro(
            title: "Chào mừng trở lại",
            subtitle: "Đăng nhập để tiếp tục đặt sân yêu thích của bạn.",
          ),
          const SizedBox(height: 24),
          AuthTextField(
            controller: emailController,
            label: "Địa chỉ email",
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.mail_outline,
            errorText: emailError,
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: passwordController,
            label: "Mật khẩu",
            obscureText: !showPassword,
            prefixIcon: Icons.lock_outline,
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
          const SizedBox(height: 16),
          AuthRememberForgotRow(
            rememberMe: rememberMe,
            onToggleRemember: onToggleRemember,
            onForgotPassword: onForgotPassword,
          ),
          const SizedBox(height: 24),
          AuthFormError(message: formError),
          if (formError != null && formError!.isNotEmpty)
            const SizedBox(height: 12),
          AuthSubmitButton(
            label: "Đăng nhập",
            successLabel: "Đăng nhập thành công!",
            isLoading: isLoading,
            isSuccess: isSuccess,
            onPressed: onSubmit,
          ),
          const AuthDivider(),
          AuthSocialButton(label: "Tiếp tục với Google", onPressed: () {}),
          const SizedBox(height: 24),
          AuthFooterLink(
            prompt: "Chưa có tài khoản? ",
            actionLabel: "Đăng ký ngay",
            onTap: onRegister,
          ),
          const SizedBox(height: 16),
          const AuthTermsFooter(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
