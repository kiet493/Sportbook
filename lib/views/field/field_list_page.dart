import 'package:flutter/material.dart';

import '../../models/venue.dart';
import 'field_search_page.dart';

/// Màn danh sách sân. Tái sử dụng bộ lọc/tìm kiếm của [FieldSearchPage]
/// để danh sách và kết quả tìm kiếm luôn dùng cùng một nguồn Firestore.
class FieldListPage extends StatelessWidget {
  final VoidCallback onBack;
  final ValueChanged<Venue> onVenueTap;
  final ValueChanged<String> onNav;
  final String activeNav;

  const FieldListPage({
    super.key,
    required this.onBack,
    required this.onVenueTap,
    required this.onNav,
    required this.activeNav,
  });

  @override
  Widget build(BuildContext context) => FieldSearchPage(
    onBack: onBack,
    onVenueTap: onVenueTap,
    onNav: onNav,
    activeNav: activeNav,
  );
}
