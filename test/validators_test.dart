import 'package:flutter_test/flutter_test.dart';
import 'package:sumadhura_visitor/core/utils/validators.dart';

void main() {
  group('Field Validation Rule Tests', () {
    test('Name validator enforces non-empty and minimum length', () {
      expect(Validators.validateName(null), isNotNull);
      expect(Validators.validateName(''), isNotNull);
      expect(Validators.validateName(' '), isNotNull);
      expect(Validators.validateName('A'), isNotNull);
      expect(Validators.validateName('Al'), isNull);
      expect(Validators.validateName('Vikram Malhotra'), isNull);
    });

    test('Purpose validator enforces mandatory input', () {
      expect(Validators.validatePurpose(null), isNotNull);
      expect(Validators.validatePurpose(''), isNotNull);
      expect(Validators.validatePurpose('  '), isNotNull);
      expect(Validators.validatePurpose('Site inspection'), isNull);
    });

    test('Mobile validator strictly enforces exactly 10 digits', () {
      expect(Validators.validateMobile(null), isNotNull);
      expect(Validators.validateMobile(''), isNotNull);
      expect(Validators.validateMobile('12345'), isNotNull);
      expect(Validators.validateMobile('12345678901'), isNotNull); // 11 digits
      expect(Validators.validateMobile('abcdefghij'), isNotNull);
      expect(Validators.validateMobile('9876543210'), isNull); // Valid 10 digits
    });

    test('Email validator allows optional empty or requires valid format', () {
      expect(Validators.validateEmail(null), isNull); // Optional
      expect(Validators.validateEmail(''), isNull); // Optional
      expect(Validators.validateEmail('invalid-email'), isNotNull);
      expect(Validators.validateEmail('test@com'), isNotNull);
      expect(Validators.validateEmail('contact@sumadhura.com'), isNull);
    });
  });
}
