part of '../extensions_tests.dart';

void _stringTests() {
  group('StringExtension Tests', () {
    test(
        'overflow returns truncated string with ellipsis when length exceeds limit',
        () {
      const text = 'Hello World';
      expect(text.overflow(5), equals('Hello...'));
    });

    test('overflow returns original string when length is within limit', () {
      const text = 'Hello';
      expect(text.overflow(5), equals('Hello'));
    });

    test('isNumber returns true for valid numbers', () {
      expect('123'.isNumber, isTrue);
      expect('12.34'.isNumber, isTrue);
      expect('-123'.isNumber, isTrue);
      expect('-12.34'.isNumber, isTrue);
    });

    test('isNumber returns false for invalid numbers', () {
      expect('abc'.isNumber, isFalse);
      expect(''.isNumber, isFalse);
      expect('12.34.56'.isNumber, isFalse);
    });
  });

  group('NullableString Tests', () {
    test('convertToDouble returns null for null or empty string', () {
      String? nullString;
      expect(nullString.convertToDouble(), isNull);
      expect(''.convertToDouble(), isNull);
    });

    test('convertToDouble returns double for valid number string', () {
      expect('123.45'.convertToDouble(), equals(123.45));
      expect('-123.45'.convertToDouble(), equals(-123.45));
    });

    test('isNotNullOrEmpty returns true for non-null non-empty string', () {
      expect('test'.isNotNullOrEmpty(), isTrue);
    });

    test('isNotNullOrEmpty returns false for null or empty string', () {
      String? nullString;
      expect(nullString.isNotNullOrEmpty(), isFalse);
      expect(''.isNotNullOrEmpty(), isFalse);
    });
  });
}
