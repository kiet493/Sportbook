import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import '../providers/registration_providers.dart';
import '../views/admin/manage_users_page.dart';
import '../views/admin/user_detail_page.dart';

/// Named route catalogue for the new (Riverpod-powered) screens.
///
/// Keeping the strings in one place avoids the "typo in route name"
/// class of bugs and gives a single grep target when refactoring.
class AppRoutes {
  AppRoutes._();

  static const String manageUsers = 'admin/manage-users';
  static const String userDetail = 'admin/user-detail';
}

/// Router for screens backed by the Manage Account module.
///
/// Hook it up via `MaterialApp.onGenerateRoute` or by pushing named
/// routes with `Navigator.pushNamed`. The existing app-level
/// controller in `app.dart` is left untouched on purpose — this
/// router only owns the new admin flows.
class AppRouter {
  AppRouter._();

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.manageUsers:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const RoleGuard(
            requiredRole: UserRole.admin,
            child: ManageUsersPage(),
          ),
        );
      case AppRoutes.userDetail:
        final user = settings.arguments;
        if (user is! UserModel) {
          return _errorRoute('Thiếu dữ liệu người dùng');
        }
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => RoleGuard(
            requiredRole: UserRole.admin,
            child: UserDetailPage(user: user),
          ),
        );
      default:
        return null;
    }
  }
}

/// Wraps any screen that requires authentication. Redirects to login
/// when the session is empty and renders a "banned" / "forbidden"
/// placeholder when the current user doesn't have access.
class RoleGuard extends ConsumerWidget {
  final Widget child;
  final String? requiredRole;

  const RoleGuard({super.key, required this.child, this.requiredRole});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);

    if (session == null) {
      // Defer to the next frame so we don't navigate during build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        Navigator.of(context).maybePop();
      });
      return const _LoadingScaffold();
    }

    final user = session.user;
    if (user.isBanned) {
      return const _BannedScaffold();
    }

    if (!_hasRequiredRole(user, requiredRole)) {
      return const _ForbiddenScaffold();
    }

    return child;
  }
}

bool _hasRequiredRole(UserModel user, String? requiredRole) {
  switch (requiredRole) {
    case null:
      return true;
    case UserRole.admin:
      return user.isAdmin;
    case UserRole.staff:
      return user.isStaff || user.isAdmin;
    case UserRole.user:
      return true;
    default:
      return user.role.trim().toLowerCase() == requiredRole;
  }
}

class _LoadingScaffold extends StatelessWidget {
  const _LoadingScaffold();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class _BannedScaffold extends StatelessWidget {
  const _BannedScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tài khoản bị khóa')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Tài khoản của bạn đã bị tạm khóa. Vui lòng liên hệ quản trị viên.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _ForbiddenScaffold extends StatelessWidget {
  const _ForbiddenScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Không có quyền truy cập')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Bạn không có quyền truy cập chức năng này.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

Route<dynamic> _errorRoute(String message) => MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Lỗi')),
        body: Center(child: Text(message)),
      ),
    );
