import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/booking_providers.dart';
import '../../providers/manage_users_providers.dart';
import '../../providers/registration_providers.dart';
import 'admin_bookings_page.dart';
import 'manage_consumables_page.dart';
import 'manage_equipment_page.dart';
import 'manage_news_page.dart';
import 'manage_policies_page.dart';
import 'manage_users_page.dart';
import 'manage_venues_page.dart';
import 'statistics_page.dart';

enum _AdminSection {
  dashboard,
  users,
  venues,
  bookings,
  equipment,
  consumables,
  news,
  policies,
  statistics,
}

class AdminDashboardPage extends ConsumerStatefulWidget {
  final VoidCallback onLogout;

  const AdminDashboardPage({super.key, required this.onLogout});

  @override
  ConsumerState<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage> {
  _AdminSection _section = _AdminSection.dashboard;
  bool _loggingOut = false;

  @override
  Widget build(BuildContext context) {
    final child = switch (_section) {
      _AdminSection.users => ManageUsersPage(onBack: _showDashboard),
      _AdminSection.venues => ManageVenuesPage(onBack: _showDashboard),
      _AdminSection.bookings => AdminBookingsPage(onBack: _showDashboard),
      _AdminSection.equipment => ManageEquipmentPage(onBack: _showDashboard),
      _AdminSection.consumables => ManageConsumablesPage(
        onBack: _showDashboard,
      ),
      _AdminSection.news => ManageNewsPage(onBack: _showDashboard),
      _AdminSection.policies => ManagePoliciesPage(onBack: _showDashboard),
      _AdminSection.statistics => StatisticsPage(onBack: _showDashboard),
      _AdminSection.dashboard => _DashboardHome(
        onOpenUsers: () => _open(_AdminSection.users),
        onOpenVenues: () => _open(_AdminSection.venues),
        onOpenBookings: () => _open(_AdminSection.bookings),
        onOpenEquipment: () => _open(_AdminSection.equipment),
        onOpenConsumables: () => _open(_AdminSection.consumables),
        onOpenNews: () => _open(_AdminSection.news),
        onOpenPolicies: () => _open(_AdminSection.policies),
        onOpenStatistics: () => _open(_AdminSection.statistics),
        onLogout: _confirmLogout,
        loggingOut: _loggingOut,
      ),
    };

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _section != _AdminSection.dashboard) {
          _showDashboard();
        }
      },
      child: child,
    );
  }

  void _open(_AdminSection section) => setState(() => _section = section);

  void _showDashboard() => _open(_AdminSection.dashboard);

  Future<void> _confirmLogout() async {
    if (_loggingOut) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất?'),
        content: const Text('Bạn sẽ rời khỏi khu vực quản trị SportBook.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Ở lại'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _loggingOut = true);
    await ref.read(loginProvider.notifier).logout();
    if (!mounted) return;
    widget.onLogout();
  }
}

class _DashboardHome extends ConsumerWidget {
  final VoidCallback onOpenUsers;
  final VoidCallback onOpenVenues;
  final VoidCallback onOpenBookings;
  final VoidCallback onOpenEquipment;
  final VoidCallback onOpenConsumables;
  final VoidCallback onOpenNews;
  final VoidCallback onOpenPolicies;
  final VoidCallback onOpenStatistics;
  final VoidCallback onLogout;
  final bool loggingOut;

  const _DashboardHome({
    required this.onOpenUsers,
    required this.onOpenVenues,
    required this.onOpenBookings,
    required this.onOpenEquipment,
    required this.onOpenConsumables,
    required this.onOpenNews,
    required this.onOpenPolicies,
    required this.onOpenStatistics,
    required this.onLogout,
    required this.loggingOut,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final users = ref.watch(allUsersProvider);
    final venues = ref.watch(managedVenuesProvider);
    final courts = ref.watch(allSportCourtsProvider);
    final bookings = ref.watch(adminBookingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: loggingOut ? null : onLogout,
            icon: const Icon(Icons.logout, color: AppColors.danger, size: 18),
            label: const Text(
              'Đăng xuất',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(allUsersProvider);
            ref.invalidate(managedVenuesProvider);
            ref.invalidate(allSportCourtsProvider);
            ref.invalidate(adminBookingsProvider);
            await Future<void>.delayed(const Duration(milliseconds: 250));
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            children: [
              _WelcomeCard(name: session?.user.fullName ?? 'Quản trị viên'),
              const SizedBox(height: 18),
              const Text(
                'Tổng quan hệ thống',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.45,
                children: [
                  _MetricCard(
                    icon: Icons.people_alt_outlined,
                    label: 'Người dùng',
                    value: _count(users),
                    color: AppColors.primary,
                  ),
                  _MetricCard(
                    icon: Icons.stadium_outlined,
                    label: 'Cụm sân',
                    value: _count(venues),
                    color: AppColors.success,
                  ),
                  _MetricCard(
                    icon: Icons.sports_tennis,
                    label: 'Sân con',
                    value: _count(courts),
                    color: const Color(0xFFF97316),
                  ),
                  _MetricCard(
                    icon: Icons.event_note_outlined,
                    label: 'Booking',
                    value: _count(bookings),
                    color: const Color(0xFF7C3AED),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              const Text(
                'Chức năng quản trị',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              _AdminActionCard(
                icon: Icons.manage_accounts_outlined,
                title: 'Quản lý người dùng',
                subtitle: 'Thêm, sửa, khóa và phân quyền tài khoản',
                color: AppColors.primary,
                onTap: onOpenUsers,
              ),
              const SizedBox(height: 10),
              _AdminActionCard(
                icon: Icons.stadium_outlined,
                title: 'Quản lý sân',
                subtitle: 'Quản lý cụm sân và các sân con',
                color: AppColors.success,
                onTap: onOpenVenues,
              ),
              const SizedBox(height: 10),
              _AdminActionCard(
                icon: Icons.history,
                title: 'Lịch sử đặt sân',
                subtitle: 'Xem booking của toàn bộ người dùng',
                color: const Color(0xFF7C3AED),
                onTap: onOpenBookings,
              ),
              const SizedBox(height: 10),
              _AdminActionCard(
                icon: Icons.sports_tennis,
                title: 'Quản lý thiết bị',
                subtitle: 'CRUD thiết bị cho thuê và sử dụng tại sân',
                color: const Color(0xFF0F766E),
                onTap: onOpenEquipment,
              ),
              const SizedBox(height: 10),
              _AdminActionCard(
                icon: Icons.inventory_2_outlined,
                title: 'Quản lý vật tư tiêu hao',
                subtitle: 'Theo dõi số lượng, đơn vị và đơn giá vật tư',
                color: const Color(0xFFF97316),
                onTap: onOpenConsumables,
              ),
              const SizedBox(height: 10),
              _AdminActionCard(
                icon: Icons.newspaper_outlined,
                title: 'Quản lý tin tức',
                subtitle: 'Soạn, sửa, xuất bản và xóa bài viết',
                color: const Color(0xFF0284C7),
                onTap: onOpenNews,
              ),
              const SizedBox(height: 10),
              _AdminActionCard(
                icon: Icons.policy_outlined,
                title: 'Quản lý chính sách',
                subtitle: 'CRUD danh mục và nội dung chính sách',
                color: const Color(0xFF9333EA),
                onTap: onOpenPolicies,
              ),
              const SizedBox(height: 10),
              _AdminActionCard(
                icon: Icons.insights_outlined,
                title: 'Thống kê',
                subtitle: 'Người dùng, sân, booking, nội dung và kho',
                color: const Color(0xFFDC2626),
                onTap: onOpenStatistics,
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: loggingOut ? null : onLogout,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  minimumSize: const Size(double.infinity, 52),
                  side: const BorderSide(color: AppColors.dangerSoft),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: loggingOut
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.logout),
                label: const Text('Đăng xuất'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _count<T>(AsyncValue<List<T>> value) {
    if (value.hasError) return '—';
    return value.valueOrNull?.length.toString() ?? '…';
  }
}

class _WelcomeCard extends StatelessWidget {
  final String name;

  const _WelcomeCard({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1D4ED8), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.admin_panel_settings,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Xin chào, Admin',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 3),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Khu vực quản trị hệ thống SportBook',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _AdminActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
