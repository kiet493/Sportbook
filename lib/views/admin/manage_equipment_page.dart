import 'package:flutter/material.dart';

import '../../providers/admin_content_providers.dart';
import 'inventory_management_page.dart';

class ManageEquipmentPage extends StatelessWidget {
  final VoidCallback onBack;
  const ManageEquipmentPage({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) => InventoryManagementPage(
    title: 'Quản lý thiết bị',
    collection: 'equipments',
    itemLabel: 'thiết bị',
    watchItems: (ref) => ref.watch(equipmentProvider),
    onBack: onBack,
  );
}
