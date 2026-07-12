import 'package:flutter_test/flutter_test.dart';
import 'package:sportbook/core/utils/auth_validators.dart';

void main() {
  group('AuthValidators', () {
    test('normalises email and Vietnamese phone', () {
      expect(
        AuthValidators.normaliseEmail(' User@Example.COM '),
        'user@example.com',
      );
      expect(AuthValidators.normalisePhone('090 123-4567'), '0901234567');
    });

    test('validates registration fields', () {
      expect(AuthValidators.fullName('Nguyễn Văn An'), isNull);
      expect(AuthValidators.email('an@example.com'), isNull);
      expect(AuthValidators.phone('0901234567'), isNull);
      expect(AuthValidators.registrationPassword('123456'), isNull);
      expect(AuthValidators.registrationPassword('password'), isNull);
    });

    test('rejects malformed registration data', () {
      expect(AuthValidators.fullName('1'), isNotNull);
      expect(AuthValidators.email('not-an-email'), isNotNull);
      expect(AuthValidators.phone('12345'), isNotNull);
      expect(AuthValidators.registrationPassword('12345'), isNotNull);
      expect(AuthValidators.confirmPassword('123456', '123457'), isNotNull);
    });
  });
}
