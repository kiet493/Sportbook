import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/staff_sale.dart';
import '../../models/staff_report.dart';

class StaffFirestoreService {
  StaffFirestoreService({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _sales =>
      _db.collection('staffSales');
  CollectionReference<Map<String, dynamic>> get _reports =>
      _db.collection('staffReports');

  Stream<List<StaffSale>> watchVenueSales(String venueId) => _sales
      .where('venueId', isEqualTo: venueId)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => StaffSale.fromJson(doc.data(), doc.id))
            .toList(growable: false),
      );

  Future<void> saveSale(StaffSale sale) async {
    if (sale.bookingId.isEmpty ||
        sale.venueId.isEmpty ||
        sale.staffId.isEmpty ||
        sale.waterQuantity < 0 ||
        sale.racketQuantity < 0) {
      throw ArgumentError('Thông tin bán hàng không hợp lệ.');
    }
    await _sales.doc(sale.bookingId).set({
      ...sale.toJson(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<List<StaffReport>> watchAllReports() =>
      _reports.snapshots().map((snapshot) {
        final items = snapshot.docs
            .map((doc) => StaffReport.fromJson(doc.data(), doc.id))
            .toList();
        items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return items;
      });

  Stream<List<StaffReport>> watchStaffReports(String staffId) =>
      _reports.where('staffId', isEqualTo: staffId).snapshots().map((snapshot) {
        final items = snapshot.docs
            .map((doc) => StaffReport.fromJson(doc.data(), doc.id))
            .toList();
        items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return items;
      });

  Future<void> createReport(StaffReport report) async {
    final reference = _reports.doc();
    await reference.set({
      ...report.toJson(),
      '_id': reference.id,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setReportResolved(String reportId, bool resolved) =>
      _reports.doc(reportId).update({
        'resolved': resolved,
        'resolvedAt': resolved ? FieldValue.serverTimestamp() : null,
        'updatedAt': FieldValue.serverTimestamp(),
      });
}
