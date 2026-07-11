import 'package:flutter_test/flutter_test.dart';
import 'package:sportbook/models/user_model.dart';

void main() {
  test('new registration serialises all required Firebase profile fields', () {
    final user = UserModel.newUser(
      id: 'firebase-uid',
      fullName: 'Nguyễn Văn An',
      email: 'an@example.com',
      phone: '0901234567',
    );
    final json = user.toJson();

    expect(json['id'], 'firebase-uid');
    expect(json['firebaseUID'], 'firebase-uid');
    expect(json['fullName'], 'Nguyễn Văn An');
    expect(json['email'], 'an@example.com');
    expect(json['phone'], '0901234567');
    expect(json['phoneNumber'], '0901234567');
    expect(json['role'], UserRole.user);
    expect(json['gender'], UserGender.other);
    expect(json['status'], UserStatus.active);
    expect(json['isBanned'], false);
    expect(json, containsPair('avatarUrl', ''));
    expect(json, containsPair('address', ''));
    expect(json, contains('dateOfBirth'));
    expect(json['createdAt'], isNotEmpty);
    expect(json['updatedAt'], isNotEmpty);
  });
}
