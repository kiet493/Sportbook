import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/bottom_nav.dart';
import '../../providers/registration_providers.dart';
import '../../routes/app_router.dart';
import 'widgets/widgets.dart';

class ProfilePage extends ConsumerWidget {
  final ValueChanged<String> onNav;
  final String activeNav;
  final VoidCallback onLogout;

  const ProfilePage({
    super.key,
    required this.onNav,
    required this.activeNav,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final showAdmin =
        session != null && !session.user.isBanned && session.user.isAdmin;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const ProfileHeader(),
            Expanded(
              child: ProfileContent(
                onHistoryTap: () => onNav('history'),
                onFavoritesTap: () => onNav('favorites'),
                onLogout: onLogout,
                onManageUsersTap: showAdmin
                    ? () => Navigator.of(context).pushNamed(
                          AppRoutes.manageUsers,
                        )
                    : null,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        activeScreen: activeNav,
        onNav: onNav,
      ),
    );
  }
}
