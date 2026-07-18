import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/admin_content_models.dart';
import '../../providers/admin_content_providers.dart';

class ManagePoliciesPage extends ConsumerWidget {
  final VoidCallback onBack;
  const ManagePoliciesPage({super.key, required this.onBack});

  Future<void> _editCategory(
    BuildContext context,
    WidgetRef ref, [
    PolicyCategory? category,
  ]) async {
    final result = await showDialog<PolicyCategory>(
      context: context,
      builder: (_) => _CategoryDialog(category: category),
    );
    if (result == null) return;
    final error = await ref
        .read(adminContentActionProvider.notifier)
        .savePolicyCategory(result);
    if (context.mounted && error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Future<void> _editPolicy(
    BuildContext context,
    WidgetRef ref,
    List<PolicyCategory> categories, [
    PolicyDocument? policy,
  ]) async {
    final result = await showDialog<PolicyDocument>(
      context: context,
      builder: (_) => _PolicyDialog(policy: policy, categories: categories),
    );
    if (result == null) return;
    final error = await ref
        .read(adminContentActionProvider.notifier)
        .savePolicy(result);
    if (context.mounted && error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    String title,
    Future<String?> Function() delete,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xóa $title?'),
        content: const Text(
          'Dữ liệu liên quan sẽ bị xóa khỏi Firebase và không thể khôi phục.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final error = await delete();
    if (context.mounted && error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(policyCategoriesProvider);
    final policiesAsync = ref.watch(policiesProvider);
    final categories = categoriesAsync.valueOrNull ?? const <PolicyCategory>[];
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        title: const Text('Quản lý chính sách'),
        actions: [
          TextButton.icon(
            onPressed: () => _editCategory(context, ref),
            icon: const Icon(Icons.create_new_folder_outlined),
            label: const Text('Danh mục'),
          ),
        ],
      ),
      body: categoriesAsync.isLoading || policiesAsync.isLoading
          ? const Center(child: CircularProgressIndicator())
          : categoriesAsync.hasError || policiesAsync.hasError
          ? const Center(child: Text('Không thể tải dữ liệu chính sách.'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Danh mục',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                if (categories.isEmpty)
                  const Card(
                    child: ListTile(
                      title: Text('Chưa có danh mục chính sách.'),
                    ),
                  ),
                for (final category in categories)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.folder_outlined),
                      title: Text(
                        category.name,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      subtitle: Text(category.description),
                      onTap: () => _editCategory(context, ref, category),
                      trailing: IconButton(
                        onPressed: () => _confirmDelete(
                          context,
                          category.name,
                          () => ref
                              .read(adminContentActionProvider.notifier)
                              .deletePolicyCategory(category.id),
                        ),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ),
                  ),
                const SizedBox(height: 22),
                const Text(
                  'Chính sách',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                if (policiesAsync.valueOrNull?.isEmpty ?? true)
                  const Card(
                    child: ListTile(title: Text('Chưa có chính sách.')),
                  ),
                for (final policy
                    in policiesAsync.valueOrNull ?? const <PolicyDocument>[])
                  Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: policy.active
                            ? const Color(0xFFDCFCE7)
                            : const Color(0xFFF1F5F9),
                        child: const Icon(Icons.policy_outlined),
                      ),
                      title: Text(
                        policy.title,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      subtitle: Text(
                        _categoryName(categories, policy.categoryId),
                      ),
                      onTap: () =>
                          _editPolicy(context, ref, categories, policy),
                      trailing: IconButton(
                        onPressed: () => _confirmDelete(
                          context,
                          policy.title,
                          () => ref
                              .read(adminContentActionProvider.notifier)
                              .deletePolicy(policy.id),
                        ),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ),
                  ),
                const SizedBox(height: 80),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: categories.isEmpty
            ? null
            : () => _editPolicy(context, ref, categories),
        icon: const Icon(Icons.add),
        label: const Text('Thêm chính sách'),
      ),
    );
  }
}

String _categoryName(List<PolicyCategory> categories, String id) {
  for (final category in categories) {
    if (category.id == id) return category.name;
  }
  return 'Chưa phân loại';
}

class _CategoryDialog extends StatefulWidget {
  final PolicyCategory? category;
  const _CategoryDialog({required this.category});

  @override
  State<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<_CategoryDialog> {
  late final TextEditingController _name;
  late final TextEditingController _description;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.category?.name ?? '');
    _description = TextEditingController(
      text: widget.category?.description ?? '',
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.category == null ? 'Thêm danh mục' : 'Sửa danh mục'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _name,
          decoration: const InputDecoration(labelText: 'Tên danh mục'),
        ),
        TextField(
          controller: _description,
          decoration: const InputDecoration(labelText: 'Mô tả'),
          maxLines: 3,
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Hủy'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(
          context,
          PolicyCategory(
            id: widget.category?.id ?? '',
            name: _name.text,
            description: _description.text,
          ),
        ),
        child: const Text('Lưu'),
      ),
    ],
  );
}

class _PolicyDialog extends StatefulWidget {
  final PolicyDocument? policy;
  final List<PolicyCategory> categories;

  const _PolicyDialog({required this.policy, required this.categories});

  @override
  State<_PolicyDialog> createState() => _PolicyDialogState();
}

class _PolicyDialogState extends State<_PolicyDialog> {
  late final TextEditingController _title;
  late final TextEditingController _content;
  late String _categoryId;
  late bool _active;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.policy?.title ?? '');
    _content = TextEditingController(text: widget.policy?.content ?? '');
    final existingCategory = widget.categories.any(
      (item) => item.id == widget.policy?.categoryId,
    );
    _categoryId = existingCategory
        ? widget.policy!.categoryId
        : widget.categories.first.id;
    _active = widget.policy?.active ?? true;
  }

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.policy == null ? 'Thêm chính sách' : 'Sửa chính sách'),
    content: SizedBox(
      width: 520,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _categoryId,
              decoration: const InputDecoration(labelText: 'Danh mục'),
              items: [
                for (final category in widget.categories)
                  DropdownMenuItem(
                    value: category.id,
                    child: Text(category.name),
                  ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _categoryId = value);
              },
            ),
            TextField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Tiêu đề'),
            ),
            TextField(
              controller: _content,
              decoration: const InputDecoration(labelText: 'Nội dung'),
              maxLines: 8,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Đang áp dụng'),
              value: _active,
              onChanged: (value) => setState(() => _active = value),
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Hủy'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(
          context,
          PolicyDocument(
            id: widget.policy?.id ?? '',
            categoryId: _categoryId,
            title: _title.text,
            content: _content.text,
            active: _active,
          ),
        ),
        child: const Text('Lưu'),
      ),
    ],
  );
}
