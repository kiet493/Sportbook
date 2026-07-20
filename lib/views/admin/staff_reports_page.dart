import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/staff_report.dart';
import '../../providers/staff_providers.dart';

class StaffReportsPage extends ConsumerWidget {
  final VoidCallback onBack;

  const StaffReportsPage({super.key, required this.onBack});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reports = ref.watch(adminStaffReportsProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        title: const Text('Báo cáo từ staff'),
      ),
      body: reports.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Không tải được báo cáo: $error')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('Chưa có báo cáo.'));
          }
          final sorted = [...items]
            ..sort((a, b) {
              if (a.resolved != b.resolved) return a.resolved ? 1 : -1;
              return b.createdAt.compareTo(a.createdAt);
            });
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: sorted.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) => _ReportCard(report: sorted[index]),
          );
        },
      ),
    );
  }
}

class _ReportCard extends ConsumerWidget {
  final StaffReport report;

  const _ReportCard({required this.report});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Card(
    color: report.resolved ? const Color(0xFFF1F5F9) : Colors.white,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  report.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    decoration: report.resolved
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
              ),
              Text(
                _formatDate(report.createdAt),
                style: const TextStyle(fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            '${report.staffName} • ${report.venueName}',
            style: const TextStyle(color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 10),
          Text(report.content, style: const TextStyle(height: 1.45)),
          const Divider(height: 20),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            value: report.resolved,
            title: const Text('Đã giải quyết'),
            onChanged: (value) async {
              final error = await ref
                  .read(staffSaleActionProvider.notifier)
                  .setReportResolved(report.id, value ?? false);
              if (context.mounted && error != null) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(error)));
              }
            },
          ),
        ],
      ),
    ),
  );
}

String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
