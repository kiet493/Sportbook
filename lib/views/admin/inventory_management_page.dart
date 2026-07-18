import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/admin_content_models.dart';
import '../../providers/admin_content_providers.dart';

class InventoryManagementPage extends ConsumerWidget {
  final String title;
  final String collection;
  final String itemLabel;
  final AsyncValue<List<InventoryItem>> Function(WidgetRef ref) watchItems;
  final VoidCallback onBack;

  const InventoryManagementPage({
    super.key,
    required this.title,
    required this.collection,
    required this.itemLabel,
    required this.watchItems,
    required this.onBack,
  });

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref, [
    InventoryItem? item,
  ]) async {
    final result = await showDialog<InventoryItem>(
      context: context,
      builder: (_) => _InventoryFormDialog(item: item, itemLabel: itemLabel),
    );
    if (result == null) return;
    final error = await ref
        .read(adminContentActionProvider.notifier)
        .saveInventory(collection, result);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'Đã lưu $itemLabel.'),
        backgroundColor: error == null ? const Color(0xFF16A34A) : null,
      ),
    );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    InventoryItem item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xóa ${item.name}?'),
        content: Text('$itemLabel sẽ bị xóa khỏi Firebase.'),
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
    final error = await ref
        .read(adminContentActionProvider.notifier)
        .deleteInventory(collection, item.id);
    if (!context.mounted || error == null) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = watchItems(ref);
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        title: Text(title),
      ),
      body: items.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Không thể tải dữ liệu: $error')),
        data: (values) => values.isEmpty
            ? Center(child: Text('Chưa có $itemLabel nào.'))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: values.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = values[index];
                  return Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.fromLTRB(16, 8, 6, 8),
                      leading: CircleAvatar(
                        backgroundColor: item.active
                            ? const Color(0xFFDCFCE7)
                            : const Color(0xFFF1F5F9),
                        child: Icon(
                          collection == 'equipments'
                              ? Icons.sports_tennis
                              : Icons.inventory_2_outlined,
                        ),
                      ),
                      title: Text(
                        item.name,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      subtitle: Text(
                        'Tồn: ${item.quantity} ${item.unit} · ${_money(item.price)}',
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') _edit(context, ref, item);
                          if (value == 'delete') _delete(context, ref, item);
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: 'edit',
                            child: Text('Chỉnh sửa'),
                          ),
                          PopupMenuItem(value: 'delete', child: Text('Xóa')),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(context, ref),
        icon: const Icon(Icons.add),
        label: Text('Thêm $itemLabel'),
      ),
    );
  }
}

class _InventoryFormDialog extends StatefulWidget {
  final InventoryItem? item;
  final String itemLabel;

  const _InventoryFormDialog({required this.item, required this.itemLabel});

  @override
  State<_InventoryFormDialog> createState() => _InventoryFormDialogState();
}

class _InventoryFormDialogState extends State<_InventoryFormDialog> {
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _quantity;
  late final TextEditingController _unit;
  late final TextEditingController _price;
  late bool _active;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _name = TextEditingController(text: item?.name ?? '');
    _description = TextEditingController(text: item?.description ?? '');
    _quantity = TextEditingController(text: item?.quantity.toString() ?? '0');
    _unit = TextEditingController(text: item?.unit ?? 'cái');
    _price = TextEditingController(text: item?.price.toString() ?? '0');
    _active = item?.active ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _quantity.dispose();
    _unit.dispose();
    _price.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(
      widget.item == null
          ? 'Thêm ${widget.itemLabel}'
          : 'Sửa ${widget.itemLabel}',
    ),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Tên'),
          ),
          TextField(
            controller: _description,
            decoration: const InputDecoration(labelText: 'Mô tả'),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _quantity,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Số lượng'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _unit,
                  decoration: const InputDecoration(labelText: 'Đơn vị'),
                ),
              ),
            ],
          ),
          TextField(
            controller: _price,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Đơn giá (đ)'),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Đang sử dụng'),
            value: _active,
            onChanged: (value) => setState(() => _active = value),
          ),
        ],
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
          InventoryItem(
            id: widget.item?.id ?? '',
            name: _name.text,
            description: _description.text,
            quantity: int.tryParse(_quantity.text) ?? -1,
            unit: _unit.text,
            price: int.tryParse(_price.text) ?? -1,
            active: _active,
          ),
        ),
        child: const Text('Lưu'),
      ),
    ],
  );
}

String _money(int value) {
  final digits = value.toString();
  final result = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    result.write(digits[index]);
    final remaining = digits.length - index;
    if (remaining > 1 && remaining % 3 == 1) result.write('.');
  }
  return '$result\u0111';
}
