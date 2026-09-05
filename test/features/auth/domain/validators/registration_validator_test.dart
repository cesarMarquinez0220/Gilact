import 'package:flutter_test/flutter_test.dart';
import 'package:gilact/features/auth/domain/validators/registration_validator.dart';

void main() {
  group('RegistrationValidator', () {
    test('validateName returns error for empty name', () {
      expect(RegistrationValidator.validateName(''), 'auth.register.validation.nameRequired');
      expect(RegistrationValidator.validateName('   '), 'auth.register.validation.nameRequired');
    });

    test('validateName returns null for valid name', () {
      expect(RegistrationValidator.validateName('Maria'), isNull);
    });

    test('validateEmail returns error for invalid email', () {
      expect(RegistrationValidator.validateEmail(''), 'auth.register.validation.emailRequired');
      expect(RegistrationValidator.validateEmail('invalid-email'), 'auth.register.validation.emailInvalid');
    });

    test('validateEmail returns null for valid email', () {
      expect(RegistrationValidator.validateEmail('test@example.com'), isNull);
      expect(RegistrationValidator.validateEmail('cesarmmarquinez+guilact@gmail.com'), isNull);
    });

    test('validatePassword returns error for weak password', () {
      expect(RegistrationValidator.validatePassword(''), 'auth.register.validation.passwordRequired');
      expect(RegistrationValidator.validatePassword('12345'), 'auth.register.validation.passwordShort');
    });

    test('validatePassword returns null for strong password', () {
      expect(RegistrationValidator.validatePassword('123456'), isNull);
    });

    test('validateBirthDate returns error for future date', () {
      final futureDate = DateTime.now().add(const Duration(days: 1)).toString();
      expect(RegistrationValidator.validateBirthDate(futureDate), 'La fecha de nacimiento no puede ser futura');
    });

    test('validateBirthDate returns error for underage', () {
      final underageDate = DateTime.now().subtract(const Duration(days: 365 * 10)).toString(); // 10 years old
      expect(RegistrationValidator.validateBirthDate(underageDate), 'Debes tener al menos 16 años para registrarte');
    });

    test('validateBirthDate returns null for valid date', () {
      final validDate = DateTime.now().subtract(const Duration(days: 365 * 20)).toString(); // 20 years old
      expect(RegistrationValidator.validateBirthDate(validDate), isNull);
    });
  });
}