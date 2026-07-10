import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

/// Thin wrapper around Firebase Auth.
///
/// It only performs SDK calls. Field validation, profile creation and
/// session state are handled by the provider/repository layers.
class FirebaseAuthService {
  FirebaseAuthService({FirebaseAuth? auth}) : _auth = auth;

  final FirebaseAuth? _auth;

  FirebaseAuth get _instance {
    if (Firebase.apps.isEmpty) {
      throw FirebaseException(
        plugin: 'firebase_auth',
        code: 'no-app',
        message: 'Firebase chưa được khởi tạo',
      );
    }
    return _auth ?? FirebaseAuth.instance;
  }

  User? get currentUser => _instance.currentUser;

  Future<UserCredential> createUser({
    required String email,
    required String password,
  }) {
    return _instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> updateDisplayName(String fullName) async {
    final user = currentUser;
    if (user == null) return;
    await user.updateDisplayName(fullName);
  }

  Future<void> signOut() => _instance.signOut();

  Future<void> deleteCurrentUser() async {
    final user = currentUser;
    if (user == null) return;
    await user.delete();
  }
}
