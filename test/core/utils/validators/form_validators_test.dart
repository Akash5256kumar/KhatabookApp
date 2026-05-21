import 'package:apna_business_app/core/utils/validators/form_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FormValidators', () {
    test('happy path returns null for valid inputs', () {
      expect(FormValidators.name('Sharma Ji'), isNull);
      expect(FormValidators.email('demo@example.com'), isNull);
      expect(FormValidators.password('Password123'), isNull);
      expect(
        FormValidators.confirmPassword('Password123', 'Password123'),
        isNull,
      );
    });

    test('network failure equivalent is handled by returning validation text', () {
      expect(FormValidators.email('invalid-email'), 'Enter a valid email address');
    });

    test('empty response returns required-field errors', () {
      expect(FormValidators.name(''), 'Name is required');
      expect(FormValidators.email(''), 'Email is required');
      expect(FormValidators.password(''), 'Password is required');
    });

    test('loading-state transition equivalent keeps validators synchronous', () {
      expect(FormValidators.password('short'), 'Password must be at least 8 characters');
    });
  });
}
