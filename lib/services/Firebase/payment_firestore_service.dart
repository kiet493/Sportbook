import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/payment_models.dart';

class PaymentFirestoreService {
  PaymentFirestoreService({FirebaseFirestore? firestore}) : _db = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _db;

  Stream<List<Coupon>> watchCoupons() => _db.collection('coupons').snapshots().map((snapshot) {
    final items = snapshot.docs.map((doc) => Coupon.fromJson(doc.data(), doc.id)).where((item) => item.active).toList();
    items.sort((a, b) => a.code.compareTo(b.code));
    return items;
  });

  Stream<List<PaymentTransaction>> watchTransactions(String userId) => _db
      .collection('transactions').where('userId', isEqualTo: userId).snapshots().map((snapshot) {
        final items = snapshot.docs.map((doc) => PaymentTransaction.fromJson(doc.data(), doc.id)).toList();
        items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return items;
      });

  Future<PaymentTransaction> pay({required String bookingId, required String userId, required int subtotal, required String method, Coupon? coupon}) async {
    final now = DateTime.now();
    final validCoupon = coupon != null && coupon.isApplicableTo(subtotal, now) ? coupon : null;
    final discount = validCoupon == null
        ? 0
        : validCoupon.discountAmount.clamp(0, subtotal).toInt();
    final amount = subtotal - discount;
    final paymentRef = _db.collection('payments').doc();
    final transactionRef = _db.collection('transactions').doc();
    final bookingRef = _db.collection('bookings').doc(bookingId);
    final result = PaymentTransaction(id: transactionRef.id, bookingId: bookingId, userId: userId, amount: amount, discount: discount, method: method, status: 'paid', couponCode: validCoupon?.code ?? '', createdAt: now);
    final batch = _db.batch();
    batch.set(paymentRef, {'_id': paymentRef.id, 'bookingId': bookingId, 'userId': userId, 'amount': amount, 'discount': discount, 'method': method, 'status': 'paid', 'couponCode': result.couponCode, 'createdAt': FieldValue.serverTimestamp()});
    batch.set(transactionRef, {'_id': result.id, 'bookingId': bookingId, 'userId': userId, 'amount': amount, 'discount': discount, 'method': method, 'status': 'paid', 'couponCode': result.couponCode, 'createdAt': FieldValue.serverTimestamp()});
    batch.update(bookingRef, {'paymentStatus': 'paid', 'paymentMethod': method, 'paymentId': paymentRef.id, 'updatedAt': FieldValue.serverTimestamp()});
    await batch.commit();
    return result;
  }
}
