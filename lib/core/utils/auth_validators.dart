class AuthValidators {
  AuthValidators._();

  static final RegExp _emailPattern = RegExp(
    r"^[A-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Z0-9](?:[A-Z0-9-]{0,61}[A-Z0-9])?(?:\.[A-Z0-9](?:[A-Z0-9-]{0,61}[A-Z0-9])?)+$",
    caseSensitive: false,
  );
  static final RegExp _phonePattern = RegExp(r'^(?:\+84|0)(?:3|5|7|8|9)\d{8}$');

  static String normaliseEmail(String value) => value.trim().toLowerCase();

  static String normalisePhone(String value) =>
      value.trim().replaceAll(RegExp(r'[\s.()-]'), '');

  static String? fullName(String value) {
    final name = value.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (name.isEmpty) return 'Vui lòng nhập họ tên';
    if (name.length < 2) return 'Họ tên phải có ít nhất 2 ký tự';
    if (name.length > 80) return 'Họ tên không được vượt quá 80 ký tự';
    if (!RegExp(r"^[\p{L}\p{M} .'-]+$", unicode: true).hasMatch(name)) {
      return 'Họ tên chứa ký tự không hợp lệ';
    }
    return null;
  }

  static String? email(String value) {
    final email = normaliseEmail(value);
    if (email.isEmpty) return 'Vui lòng nhập email';
    if (email.length > 254 || !_emailPattern.hasMatch(email)) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  static String? phone(String value) {
    final phone = normalisePhone(value);
    if (phone.isEmpty) return 'Vui lòng nhập số điện thoại';
    if (!_phonePattern.hasMatch(phone)) {
      return 'Số điện thoại Việt Nam không hợp lệ';
    }
    return null;
  }

  static String? loginPassword(String value) =>
      value.isEmpty ? 'Vui lòng nhập mật khẩu' : null;

  static String? registrationPassword(String value) {
    if (value.isEmpty) return 'Vui lòng nhập mật khẩu';
    if (value.length < 6) return 'Mật khẩu phải có ít nhất 6 ký tự';
    if (value.length > 128) return 'Mật khẩu không được vượt quá 128 ký tự';
    return null;
  }

  static String? confirmPassword(String password, String confirmation) {
    if (confirmation.isEmpty) return 'Vui lòng xác nhận mật khẩu';
    if (password != confirmation) return 'Mật khẩu xác nhận không khớp';
    return null;
  }
}
