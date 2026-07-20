import 'package:flutter/material.dart';

import '../../../models/user_model.dart';
import '../../../core/utils/currency_formatter.dart';
import 'profile_logout_button.dart';
import 'profile_menu_button.dart';
import 'profile_user_card.dart';

class ProfileContent extends StatelessWidget {
  final UserModel? user;
  final VoidCallback onHistoryTap;
  final VoidCallback onTransactionHistoryTap;
  final VoidCallback onEditProfileTap;
  final VoidCallback onChangePasswordTap;
  final VoidCallback onFavoritesTap;
  final VoidCallback onLogout;
  final VoidCallback? onManageUsersTap;
  final VoidCallback? onManageVenuesTap;

  const ProfileContent({
    super.key,
    required this.user,
    required this.onHistoryTap,
    required this.onTransactionHistoryTap,
    required this.onEditProfileTap,
    required this.onChangePasswordTap,
    required this.onFavoritesTap,
    required this.onLogout,
    this.onManageUsersTap,
    this.onManageVenuesTap,
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(16)),
            child: Row(children: [
              const Icon(Icons.account_balance_wallet_outlined, color: Color(0xFF047857)),
              const SizedBox(width: 10),
              const Expanded(child: Text('Số dư ví', style: TextStyle(fontWeight: FontWeight.w700))),
              Text('${formatVnd(user?.walletBalance ?? 0)}đ', style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF047857))),
            ]),
          ),
          const SizedBox(height: 16),
          ProfileMenuButton(label: "Chỉnh sửa hồ sơ", onTap: onEditProfileTap),
          const SizedBox(height: 12),
          ProfileMenuButton(label: "Đổi mật khẩu", onTap: onChangePasswordTap),
          const SizedBox(height: 12),
          ProfileMenuButton(
            label: "L\u1ecbch s\u1eed \u0111\u1eb7t s\u00e2n",
            onTap: onHistoryTap,
          ),
          const SizedBox(height: 12),
          ProfileMenuButton(
            label: "L\u1ecbch s\u1eed thanh to\u00e1n",
            onTap: onTransactionHistoryTap,
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
          if (onManageVenuesTap != null) ...[
            const SizedBox(height: 12),
            ProfileMenuButton(
              label: "Qu\u1ea3n l\u00fd s\u00e2n",
              onTap: onManageVenuesTap!,
            ),
          ],
          const SizedBox(height: 24),
          ProfileLogoutButton(onPressed: onLogout),
        ],
      ),
    );
  }
}
