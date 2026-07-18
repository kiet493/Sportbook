import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/payment_models.dart';
import '../services/Firebase/payment_firestore_service.dart';

final paymentFirestoreServiceProvider = Provider<PaymentFirestoreService>((ref) => PaymentFirestoreService());
final couponsProvider = StreamProvider<List<Coupon>>((ref) => ref.watch(paymentFirestoreServiceProvider).watchCoupons());
final transactionsProvider = StreamProvider.family<List<PaymentTransaction>, String>((ref, userId) => ref.watch(paymentFirestoreServiceProvider).watchTransactions(userId));
