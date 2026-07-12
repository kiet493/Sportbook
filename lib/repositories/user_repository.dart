import '../core/utils/auth_validators.dart';
import '../models/user_model.dart';
import '../services/Firebase/firestore_service.dart';

/// Thrown by [UserRepository] when validation rules fail.
///
/// The UI layer can pattern-match on [code] to render a localised
/// message without re-parsing strings.
class UserValidationException implements Exception {
  final String code;
  final String message;

  const UserValidationException(this.code, this.message);

  @override
  String toString() => 'UserValidationException($code): $message';
}

/// All business rules for managing users live here so they can be
/// unit-tested without touching Firestore or any Riverpod state.
class UserRepository {
  UserRepository({required FirestoreService firestoreService})
    : _firestore = firestoreService;

  final FirestoreService _firestore;

  // ─── Queries ───────────────────────────────────────────────────────────

  Stream<List<UserModel>> watchAll() => _firestore.watchAllUsers();

  Future<UserModel?> fetch(String id) => _firestore.fetchUser(id);

  Future<UserModel?> fetchByEmail(String email) =>
      _firestore.fetchUserByEmail(email);

  // ─── Validation rules ──────────────────────────────────────────────────

  /// Required-field check. Returns a map of field → error message;
  /// empty map means everything passed.
  Map<String, String> validateRequired(UserModel user) {
    final errors = <String, String>{};

    final fullNameError = AuthValidators.fullName(user.fullName);
    if (fullNameError != null) errors['fullName'] = fullNameError;

    final email = user.email.trim();
    final emailError = AuthValidators.email(email);
    if (emailError != null) errors['email'] = emailError;

    final phone = user.phone.trim();
    final phoneError = AuthValidators.phone(phone);
    if (phoneError != null) errors['phone'] = phoneError;

    if (!UserRole.all.contains(user.role)) {
      errors['role'] = 'Vai trò không hợp lệ';
    }

    if (!UserGender.all.contains(user.gender)) {
      errors['gender'] = 'Giới tính không hợp lệ';
    }

    if (!UserStatus.all.contains(user.status)) {
      errors['status'] = 'Trạng thái không hợp lệ';
    }

    return errors;
  }

  /// Throws [UserValidationException] on the first failing rule.
  /// Used by the create/update flows that prefer a single error
  /// over a map.
  void ensureValid(UserModel user) {
    final errors = validateRequired(user);
    if (errors.isNotEmpty) {
      final entry = errors.entries.first;
      throw UserValidationException(entry.key, entry.value);
    }
  }

  /// Enforces email + phone uniqueness. `excludeId` lets the update
  /// path skip the row that's currently being edited.
  Future<void> ensureUnique(UserModel user, {String? excludeId}) async {
    final email = user.email.trim().toLowerCase();
    final phone = user.phone.trim();

    final dupEmail = await _firestore.findByField(
      field: 'email',
      value: email,
      excludeId: excludeId,
    );
    if (dupEmail.isNotEmpty) {
      throw const UserValidationException(
        'email',
        'Email đã được sử dụng bởi tài khoản khác',
      );
    }

    final dupPhone = await _firestore.findByField(
      field: 'phone',
      value: phone,
      excludeId: excludeId,
    );
    if (dupPhone.isNotEmpty) {
      throw const UserValidationException(
        'phone',
        'Số điện thoại đã được sử dụng bởi tài khoản khác',
      );
    }
  }

  // ─── CRUD ──────────────────────────────────────────────────────────────

  /// Validates, applies defaults, and creates the user.
  Future<UserModel> createUser(
    UserModel user, {
    bool ensureUnique = true,
    bool verifyProfileWrite = true,
  }) async {
    final normalised = _applyDefaults(user);
    ensureValid(normalised);
    if (ensureUnique) {
      await this.ensureUnique(normalised);
    }
    await _firestore.createUser(
      normalised,
      verifyProfileWrite: verifyProfileWrite,
    );
    return normalised;
  }

  Future<UserModel> updateUser(UserModel user) async {
    if (user.id.isEmpty) {
      throw const UserValidationException('id', 'Thiếu ID người dùng');
    }
    final normalised = _applyDefaults(user);
    ensureValid(normalised);
    await ensureUnique(normalised, excludeId: normalised.id);
    await _firestore.updateUser(normalised);
    return normalised;
  }

  Future<UserModel> saveAuthenticatedUserProfile(UserModel user) async {
    final normalised = _applyDefaults(user);
    ensureValid(normalised);
    await _firestore.saveAuthenticatedUserProfile(normalised);
    return normalised;
  }

  Future<void> deleteUser(String id) async {
    if (id.isEmpty) {
      throw const UserValidationException('id', 'Thiếu ID người dùng');
    }
    await _firestore.deleteUser(id);
  }

  /// Convenience helper for the admin's ban / unban toggle.
  Future<void> setBanned(String id, {required bool banned}) async {
    if (id.isEmpty) {
      throw const UserValidationException('id', 'Thiếu ID người dùng');
    }
    await _firestore.setBanned(id, banned: banned);
  }

  // ─── Helpers ───────────────────────────────────────────────────────────

  /// Applies the domain defaults that the create/update paths share:
  ///  * normalise email/phone (trim + lowercase email)
  ///  * clamp role/gender/status to known values
  ///  * always bump `updatedAt`
  UserModel _applyDefaults(UserModel user) {
    final now = DateTime.now();
    return user.copyWith(
      email: user.email.trim().toLowerCase(),
      phone: AuthValidators.normalisePhone(user.phone),
      fullName: user.fullName.trim(),
      address: user.address.trim(),
      role: UserRole.all.contains(user.role) ? user.role : UserRole.user,
      gender: UserGender.all.contains(user.gender)
          ? user.gender
          : UserGender.other,
      status: UserStatus.all.contains(user.status)
          ? user.status
          : UserStatus.active,
      updatedAt: now,
    );
  }
}
