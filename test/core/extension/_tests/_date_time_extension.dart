part of '../extensions_tests.dart';

void _dateTimeExtensionTest() {
  group('Core - DateTimeExtension', () {
    group('timeAgoSince', () {
      test('returns correct years', () {
        final date = DateTime(2021, 6, 15);
        expect(date.timeAgoSince(), '3.5 years');
      });

      test('returns correct months', () {
        final date = DateTime.now().subtract(const Duration(days: 60));
        expect(date.timeAgoSince(), '2 months');
      });

      test('returns correct days', () {
        final date = DateTime.now().subtract(const Duration(days: 5));
        expect(date.timeAgoSince(), '5 days');
      });

      test('returns 0 days for same day', () {
        final date = DateTime.now();
        expect(date.timeAgoSince(), '0 days');
      });
    });

    group('getRawDateTime', () {
      test('removes time component', () {
        final date = DateTime(2023, 6, 15, 14, 30, 45);
        final rawDate = date.getRawDateTime();
        expect(rawDate.hour, 0);
        expect(rawDate.minute, 0);
        expect(rawDate.second, 0);
        expect(rawDate.millisecond, 0);
      });

      test('preserves date component', () {
        final date = DateTime(2023, 6, 15, 14, 30, 45);
        final rawDate = date.getRawDateTime();
        expect(rawDate.year, 2023);
        expect(rawDate.month, 6);
        expect(rawDate.day, 15);
      });
    });

    group('formatDateTimeEuropean', () {
      test('formats date correctly', () {
        final date = DateTime(2023, 6, 15);
        expect(date.formatDateTimeEuropean(), '15/06/2023');
      });

      test('handles single digit day and month', () {
        final date = DateTime(2023, 5, 7);
        expect(date.formatDateTimeEuropean(), '07/05/2023');
      });
    });

    group('formatDateTimeForDueDate', () {
      test('formats date correctly', () {
        final date = DateTime(2023, 6, 15);
        expect(date.formatDateTimeForDueDate(), '15 Jun');
      });
    });

    group('formatDateTimeForCreateInvoiceDueDate', () {
      test('returns Same Day for today', () {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        expect(today.formatDateTimeForCreateInvoiceDueDate(), 'Same Day');
      });

      test('returns formatted date for other days', () {
        final date = DateTime(2023, 6, 15);
        expect(date.formatDateTimeForCreateInvoiceDueDate(), '15 Jun');
      });
    });

    group('formatUserFriendly', () {
      test('formats today correctly', () {
        final now = DateTime.now();
        expect(
          now.formatUserFriendly(),
          startsWith('${CoreStrings.today} '),
        );
      });

      test('formats yesterday correctly', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        expect(
          yesterday.formatUserFriendly(),
          startsWith('${CoreStrings.yesterday} '),
        );
      });

      test('formats last week correctly', () {
        final lastWeek = DateTime.now().subtract(const Duration(days: 6));
        expect(lastWeek.formatUserFriendly(), contains(':'));
      });

      test('formats last month in same year correctly', () {
        final lastMonth = DateTime(
          DateTime.now().year,
          DateTime.now().month - 1,
          15,
          14,
          30,
        );
        final result = lastMonth.formatUserFriendly();
        expect(result, matches(r'\d{1,2} \w+ \d{2}:\d{2}'));
      });

      test('formats previous year correctly', () {
        final lastYear = DateTime(
          DateTime.now().year - 1,
          6,
          15,
          14,
          30,
        );
        final result = lastYear.formatUserFriendly();
        expect(result, matches(r'\d{1,2} \w+ \d{4} \d{2}:\d{2}'));
      });
    });
  });
}
