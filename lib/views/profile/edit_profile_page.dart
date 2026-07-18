import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/utils/auth_validators.dart';
import '../../models/user_model.dart';
import '../../providers/registration_providers.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  final VoidCallback onBack;

  const EditProfilePage({super.key, required this.onBack});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  String _gender = UserGender.other;
  DateTime? _dateOfBirth;
  XFile? _avatar;
  Uint8List? _avatarBytes;
  String? _error;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final user = ref.read(sessionProvider)?.user;
    if (user != null) {
      _nameController.text = user.fullName;
      _phoneController.text = user.phone;
      _addressController.text = user.address;
      _gender = user.gender;
      _dateOfBirth = user.dateOfBirth;
    }
    _initialized = true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 82,
      maxWidth: 1200,
    );
    if (image == null) return;
    final bytes = await image.readAsBytes();
    if (!mounted) return;
    setState(() {
      _avatar = image;
      _avatarBytes = bytes;
      _error = null;
    });
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1920),
      lastDate: DateTime(now.year - 5, now.month, now.day),
      initialDate: _dateOfBirth ?? DateTime(now.year - 18),
    );
    if (picked != null) setState(() => _dateOfBirth = picked);
  }

  Future<void> _save() async {
    final user = ref.read(sessionProvider)?.user;
    if (user == null) return;
    final name = _nameController.text.trim();
    final phone = AuthValidators.normalisePhone(_phoneController.text);
    final validation =
        AuthValidators.fullName(name) ?? AuthValidators.phone(phone);
    if (validation != null) {
      setState(() => _error = validation);
      return;
    }

    String? avatarUrl;
    try {
      if (_avatar != null && _avatarBytes != null) {
        final extension = _avatar!.name.contains('.')
            ? _avatar!.name.split('.').last
            : 'jpg';
        avatarUrl = await ref
            .read(storageServiceProvider)
            .uploadAvatar(
              userId: user.id,
              bytes: _avatarBytes!,
              extension: extension,
            );
      }
      final error = await ref
          .read(profileProvider.notifier)
          .updateProfile(
            fullName: name,
            phone: phone,
            gender: _gender,
            address: _addressController.text,
            dateOfBirth: _dateOfBirth,
            avatarUrl: avatarUrl,
          );
      if (!mounted) return;
      if (error != null) {
        setState(() => _error = error);
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã cập nhật hồ sơ.'),
          backgroundColor: Color(0xFF16A34A),
        ),
      );
      widget.onBack();
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Không thể tải ảnh đại diện lên Firebase.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(sessionProvider)?.user;
    final loading = ref.watch(profileProvider).isLoading;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Chỉnh sửa hồ sơ'),
        leading: IconButton(
          onPressed: widget.onBack,
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 52,
                  backgroundColor: const Color(0xFFDBEAFE),
                  backgroundImage: _avatarBytes != null
                      ? MemoryImage(_avatarBytes!)
                      : (user?.avatarUrl.isNotEmpty == true
                                ? NetworkImage(user!.avatarUrl)
                                : null)
                            as ImageProvider<Object>?,
                  child:
                      _avatarBytes == null &&
                          (user == null || user.avatarUrl.isEmpty)
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: IconButton.filled(
                    onPressed: loading ? null : _pickAvatar,
                    icon: const Icon(Icons.camera_alt, size: 18),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _ProfileField(controller: _nameController, label: 'Họ và tên'),
          const SizedBox(height: 14),
          _ProfileField(
            controller: _phoneController,
            label: 'Số điện thoại',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: _gender,
            decoration: _decoration('Giới tính'),
            items: [
              for (final gender in UserGender.all)
                DropdownMenuItem(
                  value: gender,
                  child: Text(UserGender.label(gender)),
                ),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _gender = value);
            },
          ),
          const SizedBox(height: 14),
          _ProfileField(controller: _addressController, label: 'Địa chỉ'),
          const SizedBox(height: 14),
          ListTile(
            onTap: _pickBirthDate,
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            leading: const Icon(Icons.cake_outlined),
            title: const Text('Ngày sinh'),
            subtitle: Text(
              _dateOfBirth == null
                  ? 'Chưa cập nhật'
                  : '${_dateOfBirth!.day.toString().padLeft(2, '0')}/${_dateOfBirth!.month.toString().padLeft(2, '0')}/${_dateOfBirth!.year}',
            ),
            trailing: const Icon(Icons.calendar_month_outlined),
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
                : const Icon(Icons.save_outlined),
            label: const Text('Lưu thay đổi'),
          ),
        ],
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;

  const _ProfileField({
    required this.controller,
    required this.label,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: _decoration(label),
    );
  }
}

InputDecoration _decoration(String label) => InputDecoration(
  labelText: label,
  filled: true,
  fillColor: Colors.white,
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
);
