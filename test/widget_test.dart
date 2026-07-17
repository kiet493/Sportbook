import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportbook/main.dart';
import 'package:sportbook/models/court_booking.dart';
import 'package:sportbook/models/user_model.dart';
import 'package:sportbook/providers/booking_providers.dart';
import 'package:sportbook/providers/manage_users_providers.dart';
import 'package:sportbook/views/admin/admin_dashboard_page.dart';

void main() {
  test('SportBook app root can be constructed', () {
    expect(const MyApp(), isA<MyApp>());
  });

  testWidgets('admin dashboard exposes only admin management actions', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 1200);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          allUsersProvider.overrideWith(
            (ref) => Stream.value(const <UserModel>[]),
          ),
          managedVenuesProvider.overrideWith(
            (ref) => Stream.value(const <ManagedVenue>[]),
          ),
          allSportCourtsProvider.overrideWith(
            (ref) => Stream.value(const <SportCourt>[]),
          ),
          adminBookingsProvider.overrideWith(
            (ref) => Stream.value(const <CourtBooking>[]),
          ),
        ],
        child: MaterialApp(
          home: AdminDashboardPage(onLogout: () {}),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Admin Dashboard'), findsOneWidget);
    expect(find.text('Quản lý người dùng'), findsOneWidget);
    expect(find.text('Quản lý sân'), findsOneWidget);
    expect(find.text('Lịch sử đặt sân'), findsOneWidget);
    expect(find.text('Đăng xuất'), findsOneWidget);
    expect(find.text('Trang chủ'), findsNothing);

    await tester.tap(find.text('Quản lý sân'));
    await tester.pumpAndSettle();
    expect(find.text('Quản lý sân'), findsOneWidget);
    expect(find.text('Admin Dashboard'), findsNothing);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Admin Dashboard'), findsOneWidget);
    expect(find.text('Trang chủ'), findsNothing);
  });
}
