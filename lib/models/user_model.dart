import 'package:flutter/material.dart';

/// Role values used by the auth/manage-account module.
///
/// Kept as a single source of truth so the registration form,
/// the user-list filter chips, and the role guard all agree.
class UserRole {
  static const String user = 'user';
  static const String staff = 'staff';
  static const String admin = 'admin';

  static const List<String> all = [user, staff, admin];

  /// Human-readable label used in dropdowns / chips.
  static String label(String role) {
    switch (role) {
      case admin:
        return 'Quản trị viên';
      case staff:
        return 'Nhân viên';
      case user:
      default:
        return 'Người dùng';
    }
  }
}

/// Gender values for the profile/registration form.
class UserGender {
  static const String male = 'male';
  static const String female = 'female';
  static const String other = 'other';

  static const List<String> all = [male, female, other];

  static String label(String gender) {
    switch (gender) {
      case male:
        return 'Nam';
      case female:
        return 'Nữ';
      case other:
      default:
        return 'Khác';
    }
  }

  static IconData icon(String gender) {
    switch (gender) {
      case male:
        return Icons.male;
      case female:
        return Icons.female;
      case other:
      default:
        return Icons.transgender;
    }
  }
}

/// Account lifecycle status.
class UserStatus {
  static const String active = 'active';
  static const String banned = 'banned';

  static const List<String> all = [active, banned];

  static String label(String status) {
    switch (status) {
      case banned:
        return 'Đã khóa';
      case active:
      default:
        return 'Hoạt động';
    }
  }
}

/// Domain model representing a single user account.
///
/// Backed by Firestore on the remote side but kept pure-Dart so the
/// repository layer can be unit-tested without a Firebase dependency.
class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String role;
  final String gender;
  final String status;
  final String avatarUrl;
  final String address;
  final DateTime? dateOfBirth;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    required this.gender,
    required this.status,
    required this.avatarUrl,
    required this.address,
    required this.dateOfBirth,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a [UserModel] with the standard defaults used right after
  /// registration. Lets callers avoid passing every field by hand.
  factory UserModel.newUser({
    required String id,
    required String fullName,
    required String email,
    required String phone,
    String role = UserRole.user,
    String gender = UserGender.other,
  }) {
    final now = DateTime.now();
    return UserModel(
      id: id,
      fullName: fullName,
      email: email,
      phone: phone,
      role: role,
      gender: gender,
      status: UserStatus.active,
      avatarUrl: '',
      address: '',
      dateOfBirth: null,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Empty/invalid placeholder used as the AsyncNotifier seed state
  /// so the first frame does not show "loading" before the stream fires.
  factory UserModel.empty() => UserModel(
        id: '',
        fullName: '',
        email: '',
        phone: '',
        role: UserRole.user,
        gender: UserGender.other,
        status: UserStatus.active,
        avatarUrl: '',
        address: '',
        dateOfBirth: null,
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
      );

  bool get isEmpty => id.isEmpty;
  bool get isAdmin => role == UserRole.admin;
  bool get isStaff => role == UserRole.staff;
  bool get isBanned => status == UserStatus.banned;

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? role,
    String? gender,
    String? status,
    String? avatarUrl,
    String? address,
    DateTime? dateOfBirth,
    bool clearDateOfBirth = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      gender: gender ?? this.gender,
      status: status ?? this.status,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      address: address ?? this.address,
      dateOfBirth:
          clearDateOfBirth ? null : (dateOfBirth ?? this.dateOfBirth),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Serialises to a Firestore-friendly map. DateTime fields go to
  /// `FieldValue.serverTimestamp()`-style ISO strings so they remain
  /// round-trippable even when read back by the SDK.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'role': role,
      'gender': gender,
      'status': status,
      'avatarUrl': avatarUrl,
      'address': address,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Tolerant deserialiser. Accepts either ISO strings (our own
  /// writes) or Firestore `Timestamp` objects (SDK reads) for dates.
  factory UserModel.fromJson(Map<String, dynamic> json, {String? fallbackId}) {
    DateTime? parseDate(Object? raw) {
      if (raw == null) return null;
      if (raw is DateTime) return raw;
      if (raw is int) {
        return DateTime.fromMillisecondsSinceEpoch(raw);
      }
      if (raw is String && raw.isNotEmpty) {
        return DateTime.tryParse(raw);
      }
      // Firestore Timestamp exposes toDate(); duck-type instead of
      // importing the SDK here so this model stays pure-Dart.
      try {
        final dyn = raw as dynamic;
        final date = dyn.toDate();
        if (date is DateTime) return date;
      } catch (_) {/* ignore – not a Timestamp */}
      return null;
    }

    final id = (json['id'] as String?) ??
        (json['uid'] as String?) ??
        fallbackId ??
        '';
    final now = DateTime.now();
    return UserModel(
      id: id,
      fullName: (json['fullName'] as String?) ??
          (json['displayName'] as String?) ??
          '',
      email: (json['email'] as String?) ?? '',
      phone: (json['phone'] as String?) ??
          (json['phoneNumber'] as String?) ??
          '',
      role: (json['role'] as String?) ?? UserRole.user,
      gender: (json['gender'] as String?) ?? UserGender.other,
      status: (json['status'] as String?) ?? UserStatus.active,
      avatarUrl: (json['avatarUrl'] as String?) ??
          (json['photoUrl'] as String?) ??
          '',
      address: (json['address'] as String?) ?? '',
      dateOfBirth: parseDate(json['dateOfBirth']),
      createdAt: parseDate(json['createdAt']) ?? now,
      updatedAt: parseDate(json['updatedAt']) ?? now,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is UserModel && other.id == id);

  @override
  int get hashCode => id.hashCode;
}