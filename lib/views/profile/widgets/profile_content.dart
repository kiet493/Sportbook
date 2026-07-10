import 'package:flutter/material.dart';

import '../../../models/user_model.dart';
import 'profile_logout_button.dart';
import 'profile_menu_button.dart';
import 'profile_user_card.dart';

class ProfileContent extends StatelessWidget {
  final UserModel? user;
  final VoidCallback onHistoryTap;
  final VoidCallback onFavoritesTap;
  final VoidCallback onLogout;
  final VoidCallback? onManageUsersTap;

  const ProfileContent({
    super.key,
    required this.user,
    required this.onHistoryTap,
    required this.onFavoritesTap,
    required this.onLogout,
    this.onManageUsersTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProfileUserCard(user: user),
          const SizedBox(height: 16),
          ProfileMenuButton(
            label: "L\u1ecbch s\u1eed \u0111\u1eb7t s\u00e2n",
            onTap: onHistoryTap,
          ),
          const SizedBox(height: 12),
          ProfileMenuButton(
            label: "S\u00e2n y\u00eau th\u00edch",
            onTap: onFavoritesTap,
          ),
          if (onManageUsersTap != null) ...[
            const SizedBox(height: 12),
            ProfileMenuButton(
              label: "Qu\u1ea3n l\u00fd t\u00e0i kho\u1ea3n",
              onTap: onManageUsersTap!,
            ),
          ],
          const SizedBox(height: 24),
          ProfileLogoutButton(onPressed: onLogout),
        ],
      ),
    );
  }
}
