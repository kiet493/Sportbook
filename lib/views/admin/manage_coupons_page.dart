import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/payment_models.dart';
import '../../providers/payment_providers.dart';

class ManageCouponsPage extends ConsumerWidget {
  final VoidCallback onBack;
  const ManageCouponsPage({super.key, required this.onBack});

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref, [
    Coupon? coupon,
  ]) async {
    final result = await showDialog<Coupon>(
      context: context,
      builder: (_) => _CouponDialog(coupon: coupon),
    );
    if (result == null) return;
    final error = await ref.read(couponActionProvider.notifier).save(result);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'Đã lưu mã giảm giá.'),
        backgroundColor: error == null ? AppColors.success : AppColors.danger,
      ),
    );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    Coupon coupon,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa mã giảm giá?'),
        content: Text('Mã: ${coupon.code}\n${coupon.title}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final error = await ref.read(couponActionProvider.notifier).delete(coupon.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'Đã xóa mã giảm giá.'),
        backgroundColor: error == null ? AppColors.success : AppColors.danger,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final couponsAsync = ref.watch(allCouponsProvider);
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        title: const Text(
          'Quản lý mã giảm giá',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: couponsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('Không thể tải danh sách mã: $error'),
        ),
        data: (items) => items.isEmpty
            ? const Center(child: Text('Chưa có mã giảm giá nào.'))
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final coupon = items[index];
                  final isExpired = coupon.expiresAt != null &&
                      coupon.expiresAt!.isBefore(now);
                  final isActive = coupon.active && !isExpired;

                  return Card(
                    color: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    elevation: 0,
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => _edit(context, ref, coupon),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppColors.successSoft
                                    : isExpired
                                        ? AppColors.dangerSoft
                                        : AppColors.surfaceMuted,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.local_offer_outlined,
                                color: isActive
                                    ? AppColors.success
                                    : isExpired
                                        ? AppColors.danger
                                        : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        coupon.code,
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      _buildStatusBadge(coupon, isExpired),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    coupon.title,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Giảm: ${formatVnd(coupon.discountAmount)}đ  •  Đơn tối thiểu: ${formatVnd(coupon.minOrder)}đ',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (coupon.expiresAt != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Hết hạn: ${_formatDate(coupon.expiresAt!)}',
                                      style: TextStyle(
                                        color: isExpired
                                            ? AppColors.dangerDeep
                                            : AppColors.textSecondary,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Xóa',
                              onPressed: () => _delete(context, ref, coupon),
                              icon: const Icon(
                                Icons.delete_outline,
                                color: AppColors.danger,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(context, ref),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Thêm mã giảm giá'),
      ),
    );
  }

  Widget _buildStatusBadge(Coupon coupon, bool isExpired) {
    if (isExpired) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.dangerSoft,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Text(
          'Hết hạn',
          style: TextStyle(
            color: AppColors.dangerDeep,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    if (!coupon.active) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Text(
          'Tắt',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.successSoft,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'Kích hoạt',
        style: TextStyle(
          color: AppColors.success,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class _CouponDialog extends StatefulWidget {
  final Coupon? coupon;
  const _CouponDialog({this.coupon});

  @override
  State<_CouponDialog> createState() => _CouponDialogState();
}

class _CouponDialogState extends State<_CouponDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _code;
  late final TextEditingController _title;
  late final TextEditingController _discountAmount;
  late final TextEditingController _minOrder;
  late bool _active;
  DateTime? _expiresAt;

  @override
  void initState() {
    super.initState();
    final coupon = widget.coupon;
    _code = TextEditingController(text: coupon?.code ?? '');
    _title = TextEditingController(text: coupon?.title ?? '');
    _discountAmount = TextEditingController(
      text: coupon != null ? '${coupon.discountAmount}' : '',
    );
    _minOrder = TextEditingController(
      text: coupon != null ? '${coupon.minOrder}' : '0',
    );
    _active = coupon?.active ?? true;
    _expiresAt = coupon?.expiresAt;
  }

  @override
  void dispose() {
    _code.dispose();
    _title.dispose();
    _discountAmount.dispose();
    _minOrder.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiresAt ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) {
      setState(() => _expiresAt = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.coupon == null ? 'Thêm mã giảm giá' : 'Sửa mã giảm giá'),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _code,
                  decoration: const InputDecoration(
                    labelText: 'Mã giảm giá (ví dụ: KM50K)',
                    hintText: 'Nhập mã viết hoa liền nhau',
                  ),
                  textCapitalization: TextCapitalization.characters,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Vui lòng nhập mã giảm giá';
                    }
                    if (val.trim().contains(' ')) {
                      return 'Mã giảm giá không được chứa khoảng trắng';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _title,
                  decoration: const InputDecoration(
                    labelText: 'Mô tả',
                    hintText: 'ví dụ: Giảm 50k cho đơn từ 100k',
                  ),
                  validator: (val) => val == null || val.trim().isEmpty
                      ? 'Vui lòng nhập mô tả'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _discountAmount,
                  decoration: const InputDecoration(
                    labelText: 'Số tiền giảm (đ)',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Vui lòng nhập số tiền giảm';
                    }
                    final amount = int.tryParse(val.trim());
                    if (amount == null || amount < 0) {
                      return 'Số tiền giảm phải là số nguyên dương';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _minOrder,
                  decoration: const InputDecoration(
                    labelText: 'Giá trị đơn hàng tối thiểu (đ)',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Vui lòng nhập đơn hàng tối thiểu';
                    }
                    final min = int.tryParse(val.trim());
                    if (min == null || min < 0) {
                      return 'Giá trị phải là số nguyên không âm';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ngày hết hạn',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _expiresAt == null
                                ? 'Không hết hạn'
                                : '${_expiresAt!.day.toString().padLeft(2, '0')}/${_expiresAt!.month.toString().padLeft(2, '0')}/${_expiresAt!.year}',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_month),
                      label: const Text('Chọn ngày'),
                    ),
                    if (_expiresAt != null)
                      IconButton(
                        onPressed: () => setState(() => _expiresAt = null),
                        icon: const Icon(Icons.clear, color: AppColors.danger),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Kích hoạt hoạt động'),
                  value: _active,
                  onChanged: (value) => setState(() => _active = value),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              Navigator.pop(
                context,
                Coupon(
                  id: widget.coupon?.id ?? '',
                  code: _code.text.trim().toUpperCase(),
                  title: _title.text.trim(),
                  discountAmount: int.parse(_discountAmount.text.trim()),
                  minOrder: int.parse(_minOrder.text.trim()),
                  active: _active,
                  expiresAt: _expiresAt,
                ),
              );
            }
          },
          style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          child: const Text('Lưu'),
        ),
      ],
    );
  }
}
