import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/staff_sale.dart';
import '../models/staff_report.dart';
import '../services/Firebase/staff_firestore_service.dart';
import 'firebase_providers.dart';
import 'registration_providers.dart';

final staffFirestoreServiceProvider = Provider<StaffFirestoreService>((ref) {
  return StaffFirestoreService();
});

final staffVenueSalesProvider = StreamProvider.family<List<StaffSale>, String>((
  ref,
  venueId,
) {
  final auth = ref.watch(firebaseAuthStateProvider);
  final user = ref.watch(sessionProvider)?.user;
  if (auth.valueOrNull == null ||
      user == null ||
      (!user.isAdmin && (!user.isStaff || user.staffVenueId != venueId))) {
    return const Stream<List<StaffSale>>.empty();
  }
  return ref.watch(staffFirestoreServiceProvider).watchVenueSales(venueId);
});

final adminStaffReportsProvider = StreamProvider<List<StaffReport>>((ref) {
  final user = ref.watch(sessionProvider)?.user;
  if (user == null || !user.isAdmin) return const Stream.empty();
  return ref.watch(staffFirestoreServiceProvider).watchAllReports();
});

final currentStaffReportsProvider = StreamProvider<List<StaffReport>>((ref) {
  final user = ref.watch(sessionProvider)?.user;
  if (user == null || !user.isStaff) return const Stream.empty();
  return ref.watch(staffFirestoreServiceProvider).watchStaffReports(user.id);
});

class StaffSaleActionNotifier extends AsyncNotifier<void> {
  @override
  void build() {}

  Future<String?> save({
    required String bookingId,
    required String venueId,
    required String dateKey,
    required int waterQuantity,
    required int racketQuantity,
  }) async {
    final user = ref.read(sessionProvider)?.user;
    if (user == null ||
        (!user.isAdmin && (!user.isStaff || user.staffVenueId != venueId))) {
      return 'Bạn không có quyền cập nhật cụm sân này.';
    }
    state = const AsyncLoading();
    try {
      await ref
          .read(staffFirestoreServiceProvider)
          .saveSale(
            StaffSale(
              id: bookingId,
              bookingId: bookingId,
              venueId: venueId,
              dateKey: dateKey,
              staffId: user.id,
              staffName: user.fullName,
              waterQuantity: waterQuantity,
              racketQuantity: racketQuantity,
              updatedAt: DateTime.now(),
            ),
          );
      state = const AsyncData(null);
      ref.invalidate(staffVenueSalesProvider(venueId));
      return null;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return 'Không thể lưu số lượng: $error';
    }
  }

  Future<String?> sendReport({
    required String title,
    required String content,
  }) async {
    final user = ref.read(sessionProvider)?.user;
    if (user == null || !user.isStaff || user.staffVenueId.isEmpty) {
      return 'Tài khoản chưa được gán cụm sân.';
    }
    if (title.trim().isEmpty || content.trim().isEmpty) {
      return 'Vui lòng nhập tiêu đề và nội dung báo cáo.';
    }
    state = const AsyncLoading();
    try {
      await ref
          .read(staffFirestoreServiceProvider)
          .createReport(
            StaffReport(
              id: '',
              staffId: user.id,
              staffName: user.fullName,
              venueId: user.staffVenueId,
              venueName: user.staffVenueName,
              title: title.trim(),
              content: content.trim(),
              resolved: false,
              createdAt: DateTime.now(),
            ),
          );
      state = const AsyncData(null);
      ref.invalidate(currentStaffReportsProvider);
      ref.invalidate(adminStaffReportsProvider);
      return null;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return 'Không thể gửi báo cáo: $error';
    }
  }

  Future<String?> setReportResolved(String reportId, bool resolved) async {
    final user = ref.read(sessionProvider)?.user;
    if (user == null || !user.isAdmin) {
      return 'Bạn không có quyền xử lý báo cáo.';
    }
    state = const AsyncLoading();
    try {
      await ref
          .read(staffFirestoreServiceProvider)
          .setReportResolved(reportId, resolved);
      state = const AsyncData(null);
      ref.invalidate(adminStaffReportsProvider);
      return null;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return 'Không thể cập nhật báo cáo: $error';
    }
  }
}

final staffSaleActionProvider =
    AsyncNotifierProvider<StaffSaleActionNotifier, void>(
      StaffSaleActionNotifier.new,
    );
