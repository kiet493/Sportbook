import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../models/user_model.dart';
import '../../providers/manage_users_providers.dart';
import '../../repositories/user_repository.dart';
import 'widgets/user_form_fields.dart';

class UserFormDialog extends ConsumerStatefulWidget {
  final UserModel? user;
  const UserFormDialog({super.key, this.user});

  static Future<bool?> show(BuildContext context, {UserModel? user}) {
    return showDialog<bool>(
      context: context,
      builder: (_) => UserFormDialog(user: user),
    );
  }

  @override
  ConsumerState<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends ConsumerState<UserFormDialog> {
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _address;
  String _role = UserRole.user;
  String _gender = UserGender.other;
  String _status = UserStatus.active;
  bool _saving = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    _name = TextEditingController(text: u?.fullName ?? '');
    _email = TextEditingController(text: u?.email ?? '');
    _phone = TextEditingController(text: u?.phone ?? '');
    _address = TextEditingController(text: u?.address ?? '');
    if (u != null) {
      _role = u.role;
      _gender = u.gender;
      _status = u.status;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  bool get _isEdit => widget.user != null;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final notifier = ref.read(manageUsersViewModelProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);

    try {
      if (_isEdit) {
        final updated = widget.user!.copyWith(
          fullName: _name.text.trim(),
          email: _email.text.trim(),
          phone: _phone.text.trim(),
          address: _address.text.trim(),
          role: _role,
          gender: _gender,
          status: _status,
        );
        await notifier.updateUser(updated);
      } else {
        final created = UserModel.newUser(
          id: 'u_${DateTime.now().microsecondsSinceEpoch}',
          fullName: _name.text.trim(),
          email: _email.text.trim(),
          phone: _phone.text.trim(),
          role: _role,
          gender: _gender,
        ).copyWith(address: _address.text.trim(), status: _status);
        await notifier.create(created);
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            _isEdit ? 'Đã cập nhật tài khoản' : 'Đã tạo tài khoản',
          ),
        ),
      );
    } on UserValidationException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(content: Text('Không thể lưu: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.surface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _DialogHeader(
                    title:
                        _isEdit ? 'Chỉnh sửa tài khoản' : 'Tạo tài khoản',
                    onClose: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: 8),
                  _FormFieldsBlock(
                    name: _name,
                    email: _email,
                    phone: _phone,
                    address: _address,
                  ),
                  const SizedBox(height: 16),
                  _FormSelectsBlock(
                    role: _role,
                    gender: _gender,
                    status: _status,
                    onRoleChanged: (v) => setState(() => _role = v),
                    onGenderChanged: (v) => setState(() => _gender = v),
                    onStatusChanged: (v) => setState(() => _status = v),
                  ),
                  const SizedBox(height: 20),
                  FormActions(
                    saving: _saving,
                    isEdit: _isEdit,
                    onCancel: () => Navigator.of(context).pop(),
                    onSubmit: _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Internal section widgets ─────────────────────────────────────────────

class _DialogHeader extends StatelessWidget {
  final String title;
  final VoidCallback onClose;
  const _DialogHeader({required this.title, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: onClose,
        ),
      ],
    );
  }
}

class _FormFieldsBlock extends StatelessWidget {
  final TextEditingController name;
  final TextEditingController email;
  final TextEditingController phone;
  final TextEditingController address;

  const _FormFieldsBlock({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FormTextField(
          controller: name,
          label: 'Họ và tên',
          icon: Icons.person_outline,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Vui lòng nhập họ tên' : null,
        ),
        const SizedBox(height: 12),
        FormTextField(
          controller: email,
          label: 'Email',
          icon: Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
          validator: _validateEmail,
        ),
        const SizedBox(height: 12),
        FormTextField(
          controller: phone,
          label: 'Số điện thoại',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: _validatePhone,
        ),
        const SizedBox(height: 12),
        FormTextField(
          controller: address,
          label: 'Địa chỉ',
          icon: Icons.location_on_outlined,
        ),
      ],
    );
  }
}

class _FormSelectsBlock extends StatelessWidget {
  final String role;
  final String gender;
  final String status;
  final ValueChanged<String> onRoleChanged;
  final ValueChanged<String> onGenderChanged;
  final ValueChanged<String> onStatusChanged;

  const _FormSelectsBlock({
    required this.role,
    required this.gender,
    required this.status,
    required this.onRoleChanged,
    required this.onGenderChanged,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: FormDropdown<String>(
                label: 'Vai trò',
                icon: Icons.shield_outlined,
                value: role,
                options: UserRole.all,
                labelOf: UserRole.label,
                onChanged: onRoleChanged,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FormDropdown<String>(
                label: 'Giới tính',
                icon: Icons.people_outline,
                value: gender,
                options: UserGender.all,
                labelOf: UserGender.label,
                onChanged: onGenderChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        FormDropdown<String>(
          label: 'Trạng thái',
          icon: Icons.toggle_on_outlined,
          value: status,
          options: UserStatus.all,
          labelOf: UserStatus.label,
          onChanged: onStatusChanged,
        ),
      ],
    );
  }
}

// ─── Validators ───────────────────────────────────────────────────────────

final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
final _phoneRegex = RegExp(r'^[0-9+\-\s()]{8,15}$');

String? _validateEmail(String? v) {
  if (v == null || v.trim().isEmpty) return 'Vui lòng nhập email';
  if (!_emailRegex.hasMatch(v.trim())) return 'Email không hợp lệ';
  return null;
}

String? _validatePhone(String? v) {
  if (v == null || v.trim().isEmpty) return 'Vui lòng nhập số điện thoại';
  if (!_phoneRegex.hasMatch(v.trim())) return 'Số điện thoại không hợp lệ';
  return null;
}