import 'package:flutter/material.dart';

import '../../providers/admin_content_providers.dart';
import 'inventory_management_page.dart';

class ManageConsumablesPage extends StatelessWidget {
  final VoidCallback onBack;
  const ManageConsumablesPage({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) => InventoryManagementPage(
    title: 'Quản lý vật tư tiêu hao',
    collection: 'consumables',
    itemLabel: 'vật tư',
    watchItems: (ref) => ref.watch(consumablesProvider),
    onBack: onBack,
  );
}
