import 'package:flutter_test/flutter_test.dart';

import 'package:bloc_clean_architecture/core/utils/validators.dart';

void main() {
  group('Email Validator', () {
    test('should return null for valid email addresses', () {
      // Valid email addresses
      const validEmails = [
        'test@example.com',
        'user.name@domain.co.uk',
        'user+tag@example.org',
        'firstname.lastname@subdomain.domain.com',
        '123@example.com',
      ];

      for (final email in validEmails) {
        final result = Validators.validateEmail(email);
        expect(result, isNull, reason: 'Email: $email should be valid');
      }
    });

    test('should return error for invalid email addresses', () {
      // Invalid email addresses
      const invalidEmails = [
        'invalid-email',
        '@example.com',
        'user@',
        'user@.com',
        'user space@example.com',
        'user@example',
        '',
      ];

      for (final email in invalidEmails) {
        final result = Validators.validateEmail(email);
        expect(result, isNotNull, reason: 'Email: $email should be invalid');
      }
    });

    test('should return error for null email', () {
      final result = Validators.validateEmail(null);
      expect(result, equals('Email is required'));
    });

    test('should return error for empty email', () {
      final result = Validators.validateEmail('');
      expect(result, equals('Email is required'));
    });

    test('should return error for email that is too long', () {
      final longEmail = '${'a' * 95}@example.com'; // 107 characters total
      final result = Validators.validateEmail(longEmail);
      expect(result, equals('Email is too long'));
    });
  });

  group('Password Validator', () {
    test('should return null for valid passwords', () {
      const validPasswords = [
        'password123',
        '123456',
        'MySecureP@ssw0rd!',
        'abcdef',
      ];

      for (final password in validPasswords) {
        final result = Validators.validatePassword(password);
        expect(result, isNull, reason: 'Password: $password should be valid');
      }
    });

    test('should return error for passwords that are too short', () {
      const shortPasswords = ['12345', 'abc', '1'];

      for (final password in shortPasswords) {
        final result = Validators.validatePassword(password);
        expect(result, isNotNull, reason: 'Password: $password should be invalid');
        expect(result, contains('at least 6 characters'));
      }
      
      // Test empty string separately as it has a different error message
      final emptyResult = Validators.validatePassword('');
      expect(emptyResult, equals('Password is required'));
    });

    test('should return error for null password', () {
      final result = Validators.validatePassword(null);
      expect(result, equals('Password is required'));
    });
  });

  group('Confirm Password Validator', () {
    const originalPassword = 'password123';

    test('should return null when passwords match', () {
      final result = Validators.validateConfirmPassword(
        originalPassword,
        originalPassword,
      );
      expect(result, isNull);
    });

    test('should return error when passwords do not match', () {
      final result = Validators.validateConfirmPassword(
        'different_password',
        originalPassword,
      );
      expect(result, equals('Passwords do not match'));
    });

    test('should return error for null confirm password', () {
      final result = Validators.validateConfirmPassword(null, originalPassword);
      expect(result, equals('Confirm password is required'));
    });

    test('should return error for empty confirm password', () {
      final result = Validators.validateConfirmPassword('', originalPassword);
      expect(result, equals('Confirm password is required'));
    });
  });

  group('Name Validator', () {
    test('should return null for valid names', () {
      const validNames = [
        'John Doe',
        'Alice',
        'José María',
        '李明',
        'Mohammed Al-Ahmad',
        'Jean-Pierre',
      ];

      for (final name in validNames) {
        final result = Validators.validateName(name);
        expect(result, isNull, reason: 'Name: $name should be valid');
      }
    });

    test('should return error for names that are too short', () {
      const shortNames = ['A', ' ', ''];

      for (final name in shortNames) {
        final result = Validators.validateName(name);
        expect(result, isNotNull, reason: 'Name: $name should be invalid');
      }
    });

    test('should return error for names that are too long', () {
      final longName = 'A' * 51; // 51 characters
      final result = Validators.validateName(longName);
      expect(result, equals('Name is too long'));
    });

    test('should return error for null name', () {
      final result = Validators.validateName(null);
      expect(result, equals('Name is required'));
    });

    test('should handle names with only whitespace', () {
      final result = Validators.validateName('   ');
      expect(result, isNotNull);
      expect(result, contains('at least 2 characters'));
    });
  });

  group('Phone Number Validator', () {
    test('should return null for valid phone numbers', () {
      const validPhones = [
        '+1234567890',
        '1234567890',
        '+441234567890',
        '01234567890',
        '+33123456789',
      ];

      for (final phone in validPhones) {
        final result = Validators.validatePhone(phone);
        expect(result, isNull, reason: 'Phone: $phone should be valid');
      }
    });

    test('should return error for invalid phone numbers', () {
      const invalidPhones = [
        '123',
        'abc123456',
        '123-456-7890',
        '(123) 456-7890',
        '+1-234-567-890',
        '',
      ];

      for (final phone in invalidPhones) {
        final result = Validators.validatePhone(phone);
        expect(result, isNotNull, reason: 'Phone: $phone should be invalid');
      }
    });

    test('should return error for null phone', () {
      final result = Validators.validatePhone(null);
      expect(result, equals('Phone number is required'));
    });
  });

  group('Generic Validators', () {
    test('validateRequired should return error for empty values', () {
      expect(Validators.validateRequired(null, 'Field'), equals('Field is required'));
      expect(Validators.validateRequired('', 'Field'), equals('Field is required'));
      expect(Validators.validateRequired('   ', 'Field'), equals('Field is required'));
    });

    test('validateRequired should return null for non-empty values', () {
      expect(Validators.validateRequired('value', 'Field'), isNull);
      expect(Validators.validateRequired('  value  ', 'Field'), isNull);
    });

    test('validateMinLength should work correctly', () {
      expect(
        Validators.validateMinLength('abc', 5, 'Password'),
        equals('Password must be at least 5 characters'),
      );
      expect(Validators.validateMinLength('abcde', 5, 'Password'), isNull);
      expect(Validators.validateMinLength('abcdef', 5, 'Password'), isNull);
      expect(
        Validators.validateMinLength(null, 5, 'Password'),
        equals('Password is required'),
      );
    });

    test('validateMaxLength should work correctly', () {
      expect(
        Validators.validateMaxLength('abcdef', 5, 'Username'),
        equals('Username must be less than 5 characters'),
      );
      expect(Validators.validateMaxLength('abcde', 5, 'Username'), isNull);
      expect(Validators.validateMaxLength('abc', 5, 'Username'), isNull);
      expect(Validators.validateMaxLength(null, 5, 'Username'), isNull);
    });
  });

  group('Edge Cases', () {
    test('should handle special characters in email', () {
      const emailsWithSpecialChars = [
        'test.email+tag@example.com',
        'user_name@example-domain.co.uk',
        'firstname-lastname@example.org',
      ];

      for (final email in emailsWithSpecialChars) {
        final result = Validators.validateEmail(email);
        expect(result, isNull, reason: 'Email: $email should be valid');
      }
    });

    test('should handle unicode characters in name', () {
      const unicodeNames = [
        'José María',
        '李小明',
        'Владимир',
        'أحمد محمد',
      ];

      for (final name in unicodeNames) {
        final result = Validators.validateName(name);
        expect(result, isNull, reason: 'Name: $name should be valid');
      }
    });
  });
}
