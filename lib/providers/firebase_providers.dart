import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds the Firebase startup error, if initialization failed.
///
/// The value is injected from `main.dart` so auth providers can show a
/// clear message instead of throwing a late "no Firebase app" exception.
final firebaseStartupErrorProvider = Provider<String?>((ref) => null);

/// The Firebase Auth SDK is the source of truth for access to Firestore.
/// A local profile/session must never be treated as an authenticated token.
final firebaseAuthStateProvider = StreamProvider<User?>((ref) {
  if (Firebase.apps.isEmpty) return const Stream<User?>.empty();
  return FirebaseAuth.instance.userChanges();
});

class FirebaseAuthRequiredException implements Exception {
  const FirebaseAuthRequiredException();

  @override
  String toString() => 'Phiên đăng nhập Firebase đã hết hạn. Vui lòng đăng nhập lại.';
}
