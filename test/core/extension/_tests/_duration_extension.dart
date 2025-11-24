part of '../extensions_tests.dart';

void _durationTests() {
  group('NumDurationExtensions -', () {
    test('microseconds conversion', () {
      expect(5.microseconds, equals(const Duration(microseconds: 5)));
      expect(
        5.5.microseconds,
        equals(const Duration(microseconds: 6)),
      ); // rounds
    });

    test('milliseconds conversion', () {
      expect(1.milliseconds, equals(const Duration(microseconds: 1000)));
      expect(1.5.milliseconds, equals(const Duration(microseconds: 1500)));
      expect(1.ms, equals(1.milliseconds)); // alias test
    });

    test('seconds conversion', () {
      expect(1.seconds, equals(const Duration(microseconds: 1000000)));
      expect(1.5.seconds, equals(const Duration(microseconds: 1500000)));
    });

    test('minutes conversion', () {
      expect(1.minutes, equals(const Duration(minutes: 1)));
      expect(0.5.minutes, equals(const Duration(seconds: 30)));
    });

    test('hours conversion', () {
      expect(1.hours, equals(const Duration(hours: 1)));
      expect(0.5.hours, equals(const Duration(minutes: 30)));
    });

    test('days conversion', () {
      expect(1.days, equals(const Duration(days: 1)));
      expect(0.5.days, equals(const Duration(hours: 12)));
    });

    test('chaining conversions', () {
      expect(
        1.days + 2.hours + 30.minutes,
        equals(const Duration(days: 1, hours: 2, minutes: 30)),
      );
    });
  });
}
