import 'package:flutter/material.dart';

import '../../core/widgets/bottom_nav.dart';
import 'widgets/widgets.dart';

class ProfilePage extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
