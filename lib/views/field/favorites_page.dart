import 'package:flutter/material.dart';
import '../../core/widgets/bottom_nav.dart';
import 'widgets/widgets.dart';

class FavoritesPage extends StatelessWidget {
  final Function(String) onNav;
  final String activeNav;

  const FavoritesPage({
    super.key,
    required this.onNav,
    required this.activeNav,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: FavoritesEmptyState(
                onExplore: () => onNav('home'),
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

  Widget _buildHeader() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE2E8F0),
            width: 1.0,
          ),
        ),
      ),
      child: const Text(
        "Yêu thích",
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          color: Color(0xFF0F172A),
        ),
      ),
    );
  }
}
