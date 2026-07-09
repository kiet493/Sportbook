import 'dart:ui';
import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final String activeScreen;
  final Function(String) onNav;

  const CustomBottomNav({
    Key? key,
    required this.activeScreen,
    required this.onNav,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check if the current screen should activate a nav item
    bool isHomeActive = activeScreen == 'home' ||
        activeScreen == 'detail' ||
        activeScreen == 'booking' ||
        activeScreen == 'success';
    bool isSearchActive = activeScreen == 'search';
    bool isHistoryActive = activeScreen == 'history' || activeScreen == 'booking-detail';
    bool isFavoritesActive = activeScreen == 'favorites';
    bool isProfileActive = activeScreen == 'profile';

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.92),
            border: Border(
              top: BorderSide(
                color: Colors.grey.withOpacity(0.2),
                width: 1.0,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Container(
              height: 72,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // 1. Home tab
                  _buildNavItem(
                    icon: Icons.home,
                    label: 'Trang chủ',
                    isActive: isHomeActive,
                    onTap: () => onNav('home'),
                  ),

                  // 2. Discover tab
                  _buildNavItem(
                    icon: Icons.explore,
                    label: 'Khám phá',
                    isActive: isSearchActive,
                    onTap: () => onNav('search'),
                  ),

                  // 3. Central booking history tab (raised FAB look)
                  GestureDetector(
                    onTap: () => onNav('history'),
                    child: Transform.translate(
                      offset: const Offset(0, -12),
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: isHistoryActive
                              ? const Color(0xFF1D4ED8)
                              : const Color(0xFF2563EB),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2563EB).withOpacity(0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.book,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),

                  // 4. Favorites tab
                  _buildNavItem(
                    icon: Icons.favorite,
                    label: 'Yêu thích',
                    isActive: isFavoritesActive,
                    onTap: () => onNav('favorites'),
                  ),

                  // 5. Profile tab
                  _buildNavItem(
                    icon: Icons.person,
                    label: 'Cá nhân',
                    isActive: isProfileActive,
                    onTap: () => onNav('profile'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final activeColor = const Color(0xFF2563EB);
    final inactiveColor = const Color(0xFF94A3B8);

    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? activeColor : inactiveColor,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isActive ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
