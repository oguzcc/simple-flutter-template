part of '../extensions_tests.dart';

void _validationTests() {
  group('ValidationExtension -', () {
    group('isValidEmail', () {
      test('returns false for empty string', () {
        expect(''.isValidEmail(), false);
      });

      test('returns true for valid emails', () {
        expect('test@example.com'.isValidEmail(), true);
        expect('user.name@domain.co.uk'.isValidEmail(), true);
        expect('user+label@domain.com'.isValidEmail(), true);
      });

      test('returns false for invalid emails', () {
        expect('test@.com'.isValidEmail(), false);
        expect('test@com'.isValidEmail(), false);
        expect('test.com'.isValidEmail(), false);
        expect('@domain.com'.isValidEmail(), false);
      });
    });

    group('isValidOTPCode', () {
      test('returns true for valid 6-digit code', () {
        expect('123456'.isValidOTPCode(), true);
        expect('000000'.isValidOTPCode(), true);
      });

      test('returns false for invalid length', () {
        expect('12345'.isValidOTPCode(), false);
        expect('1234567'.isValidOTPCode(), false);
      });

      test('returns false for non-numeric characters', () {
        expect('12345a'.isValidOTPCode(), false);
        expect('abc123'.isValidOTPCode(), false);
      });
    });

    group('isValidPhoneNumber', () {
      test('returns false for empty string', () {
        expect(''.isValidPhoneNumber(), false);
      });

      test('returns true for valid phone number format', () {
        expect('(555) 123 4567'.isValidPhoneNumber(), true);
        expect('(123) 456 7890'.isValidPhoneNumber(), true);
      });

      test('returns false for invalid formats', () {
        expect('5551234567'.isValidPhoneNumber(), false);
        expect('555-123-4567'.isValidPhoneNumber(), false);
        expect('(555)1234567'.isValidPhoneNumber(), false);
        expect('(555) 1234567'.isValidPhoneNumber(), false);
      });
    });

    group('isValidQRCode', () {
      test('returns true for valid QR codes', () {
        expect('code123'.isValidQRCode(), true);
        expect('a1_b2.c3'.isValidQRCode(), true);
        expect('test_code'.isValidQRCode(), true);
      });

      test('returns false for too short codes', () {
        expect('abc'.isValidQRCode(), false);
      });

      test('returns false for too long codes', () {
        expect('abcdefghijklmnopq'.isValidQRCode(), false);
      });

      test('returns false for invalid characters', () {
        expect('code-123'.isValidQRCode(), false);
        expect('code@123'.isValidQRCode(), false);
        expect('code 123'.isValidQRCode(), false);
      });
    });
  });
}
