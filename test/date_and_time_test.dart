import 'dart:async';

import 'package:date_and_time/library.dart';
import 'package:test/test.dart';

void main() {
  group('DateOnly', () {
    test('creates from DateTime', () {
      final date = DateTime(2024, 3, 20);
      final dateOnly = Date(date);

      expect(dateOnly.year, 2024);
      expect(dateOnly.month, 3);
      expect(dateOnly.day, 20);
    });

    test('creates from values', () {
      final dateOnly = Date.fromValues(
        year: 2024,
        month: 3,
        day: 20,
      );

      expect(dateOnly.year, 2024);
      expect(dateOnly.month, 3);
      expect(dateOnly.day, 20);
    });

    test('equals ignores time components', () {
      final date1 = DateTime(2024, 3, 20, 14, 30, 45);
      final date2 = DateTime(2024, 3, 20, 9);
      final date3 = DateTime(2024, 3, 20, 23, 59, 59, 999);

      final dateOnly1 = Date(date1);
      final dateOnly2 = Date(date2);
      final dateOnly3 = Date(date3);

      expect(dateOnly1 == dateOnly2, true);
      expect(dateOnly2 == dateOnly3, true);
      expect(dateOnly1 == dateOnly3, true);
    });

    test('not equals for different dates', () {
      final dateOnly1 = Date.fromValues(
        year: 2024,
        month: 3,
        day: 20,
      );
      final dateOnly2 = Date.fromValues(
        year: 2024,
        month: 3,
        day: 21,
      );
      final dateOnly3 = Date.fromValues(
        year: 2024,
        month: 4,
        day: 20,
      );
      final dateOnly4 = Date.fromValues(
        year: 2025,
        month: 3,
        day: 20,
      );

      expect(dateOnly1 == dateOnly2, false);
      expect(dateOnly1 == dateOnly3, false);
      expect(dateOnly1 == dateOnly4, false);
    });

    test('handles leap years correctly', () {
      final dateOnly2024 = Date.fromValues(
        year: 2024,
        month: 2,
        day: 29,
      );
      final dateOnly2028 = Date.fromValues(
        year: 2028,
        month: 2,
        day: 29,
      );
      final dateOnlyNonLeap = Date.fromValues(
        year: 2025,
        month: 2,
        day: 28,
      );

      expect(dateOnly2024.day, 29);
      expect(dateOnly2024.month, 2);
      expect(dateOnly2028.day, 29);
      expect(dateOnly2028.month, 2);
      expect(dateOnlyNonLeap.day, 28);
      expect(dateOnlyNonLeap.month, 2);
    });

    test('handles edge cases around midnight', () {
      final justBeforeMidnight = DateTime(2024, 3, 20, 23, 59, 59, 999);
      final midnight = DateTime(2024, 3, 21);
      final justAfterMidnight = DateTime(2024, 3, 21, 0, 0, 1);

      final dateOnlyBefore = Date(justBeforeMidnight);
      final dateOnlyMidnight = Date(midnight);
      final dateOnlyAfter = Date(justAfterMidnight);

      expect(dateOnlyBefore == dateOnlyMidnight, false);
      expect(dateOnlyMidnight == dateOnlyAfter, true);
      expect(dateOnlyBefore.day, 20);
      expect(dateOnlyMidnight.day, 21);
      expect(dateOnlyAfter.day, 21);
    });

    test('supports add and subtract operations', () {
      final date = Date.fromValues(
        year: 2024,
        month: 3,
        day: 20,
      );

      final nextDay = date.add(const Duration(days: 1));
      final previousDay = date.subtract(const Duration(days: 1));

      expect(nextDay.day, 21);
      expect(previousDay.day, 19);
      expect(nextDay.month, 3);
      expect(previousDay.month, 3);
    });

    test('handles month boundaries with add/subtract', () {
      final endOfMonth = Date.fromValues(
        year: 2024,
        month: 3,
        day: 31,
      );
      final startOfMonth = Date.fromValues(
        year: 2024,
        month: 3,
        day: 1,
      );

      final nextMonth = endOfMonth.add(const Duration(days: 1));
      final previousMonth = startOfMonth.subtract(const Duration(days: 1));

      expect(nextMonth.year, 2024);
      expect(nextMonth.month, 4);
      expect(nextMonth.day, 1);
      expect(previousMonth.year, 2024);
      expect(previousMonth.month, 2);
      expect(previousMonth.day, 29); // 2024 is a leap year
    });

    test('provides weekday information', () {
      final wednesday = Date.fromValues(
        year: 2024,
        month: 3,
        day: 20,
      ); // Known Wednesday
      final thursday = Date.fromValues(
        year: 2024,
        month: 3,
        day: 21,
      );
      final tuesday = Date.fromValues(
        year: 2024,
        month: 3,
        day: 19,
      );

      expect(wednesday.weekday, DateTime.wednesday);
      expect(thursday.weekday, DateTime.thursday);
      expect(tuesday.weekday, DateTime.tuesday);
    });
  });

  group('TimeOnly', () {
    test('creates from DateTime', () {
      final date = DateTime(2024, 3, 20, 14, 30, 45);
      final timeOnly = Time(date);

      expect(timeOnly.hour, 14);
      expect(timeOnly.minute, 30);
      expect(timeOnly.second, 45);
    });

    test('creates from values', () {
      final timeOnly = Time.fromValues(
        hour: 14,
        minute: 30,
        second: 45,
      );

      expect(timeOnly.hour, 14);
      expect(timeOnly.minute, 30);
      expect(timeOnly.second, 45);
    });

    test('equals ignores date components', () {
      final date1 = DateTime(2024, 3, 20, 14, 30, 45);
      final date2 = DateTime(2024, 3, 21, 14, 30, 45);
      final date3 = DateTime(2025, 12, 31, 14, 30, 45);

      final timeOnly1 = Time(date1);
      final timeOnly2 = Time(date2);
      final timeOnly3 = Time(date3);

      expect(timeOnly1.totalSeconds, timeOnly2.totalSeconds);
      expect(timeOnly2.totalSeconds, timeOnly3.totalSeconds);
      expect(timeOnly1.totalSeconds, timeOnly3.totalSeconds);
    });

    test('compares times correctly', () {
      final earlier = Time.fromValues(hour: 14, minute: 30);
      final later = Time.fromValues(hour: 14, minute: 30, second: 1);
      final muchLater = Time.fromValues(hour: 14, minute: 31);

      expect(earlier.compareTo(later), -1);
      expect(later.compareTo(earlier), 1);
      expect(earlier.compareTo(muchLater), -60);
      expect(muchLater.compareTo(earlier), 60);
    });

    test('handles edge cases around midnight', () {
      final justBeforeMidnight = Time.fromValues(
        hour: 23,
        minute: 59,
        second: 59,
      );
      final midnight = Time.fromValues(hour: 0, minute: 0);
      final justAfterMidnight = Time.fromValues(
        hour: 0,
        minute: 0,
        second: 1,
      );

      expect(justBeforeMidnight.compareTo(midnight), 86399);
      expect(midnight.compareTo(justAfterMidnight), -1);
      expect(justBeforeMidnight.hour, 23);
      expect(justBeforeMidnight.minute, 59);
      expect(justBeforeMidnight.second, 59);
      expect(midnight.hour, 0);
      expect(midnight.minute, 0);
      expect(midnight.second, 0);
      expect(justAfterMidnight.hour, 0);
      expect(justAfterMidnight.minute, 0);
      expect(justAfterMidnight.second, 1);
    });

    test('calculates total seconds correctly', () {
      final time = Time.fromValues(
        hour: 1,
        minute: 30,
        second: 45,
      );

      // 1 hour = 3600 seconds
      // 30 minutes = 1800 seconds
      // 45 seconds
      expect(time.totalSeconds, 5445);
    });

    test('equals across different dates', () {
      final time1 = Time(DateTime(2024, 3, 20, 14, 30, 45));
      final time2 = Time(DateTime(2024, 3, 21, 14, 30, 45));
      final time3 = Time(DateTime(2025, 12, 31, 14, 30, 45));
      final differentTime = Time(DateTime(2024, 3, 20, 14, 30, 46));

      expect(time1.totalSeconds, time2.totalSeconds);
      expect(time2.totalSeconds, time3.totalSeconds);
      expect(time1.totalSeconds, time3.totalSeconds);
      expect(time1.compareTo(time2), 0);
      expect(time2.compareTo(time3), 0);
      expect(time1.compareTo(time3), 0);
      expect(time1.compareTo(differentTime), -1);
      expect(differentTime.compareTo(time1), 1);
    });

    test('sorts times in correct order', () {
      final times = [
        Time.fromValues(hour: 14, minute: 30, second: 45), // 14:30:45
        Time.fromValues(hour: 14, minute: 30), // 14:30:00
        Time.fromValues(hour: 14, minute: 31), // 14:31:00
        Time.fromValues(hour: 14, minute: 30, second: 46), // 14:30:46
        Time.fromValues(hour: 13, minute: 59, second: 59), // 13:59:59
      ];

      // Create matching DateTimes for comparison
      final dateTimes = [
        DateTime(2024, 1, 1, 14, 30, 45),
        DateTime(2024, 1, 1, 14, 30),
        DateTime(2024, 1, 1, 14, 31),
        DateTime(2024, 1, 1, 14, 30, 46),
        DateTime(2024, 1, 1, 13, 59, 59),
      ];

      final sortedTimes = [...times]..sort((a, b) => a.compareTo(b));
      final sortedDateTimes = [...dateTimes]..sort((a, b) => a.compareTo(b));

      // Convert sorted DateTimes to Times for comparison
      final expectedOrder = sortedDateTimes.map(Time.new).toList();

      for (var i = 0; i < sortedTimes.length; i++) {
        expect(
          sortedTimes[i].totalSeconds,
          expectedOrder[i].totalSeconds,
          reason: 'Time at index $i does not match expected order',
        );
      }

      // Verify the actual order we expect
      expect(
          sortedTimes.map((t) => '${t.hour}:${t.minute}:${t.second}').toList(),
          [
            '13:59:59',
            '14:30:0',
            '14:30:45',
            '14:30:46',
            '14:31:0',
          ]);
    });

    test('parses times correctly', () {
      // Valid formats
      expect(Time.tryParse('10:00'), Time.fromValues(hour: 10, minute: 0));
      expect(
        Time.tryParse('10:00:11'),
        Time.fromValues(hour: 10, minute: 0, second: 11),
        reason: 'Should allow hours, minutes and seconds',
      );
      expect(
        Time.tryParse('23:59:59'),
        Time.fromValues(hour: 23, minute: 59, second: 59),
        reason: 'Should handle end of day time',
      );
      expect(
        Time.tryParse('00:00:00'),
        Time.fromValues(hour: 0, minute: 0),
        reason: 'Should handle midnight',
      );
      expect(
        Time.tryParse('09:05:02'),
        Time.fromValues(hour: 9, minute: 5, second: 2),
        reason: 'Should handle leading zeros',
      );

      // Invalid formats
      expect(
        Time.tryParse('10'),
        null,
        reason: 'Should not allow only hours',
      );
      expect(
        Time.tryParse('24:00:00'),
        null,
        reason: 'Should not allow 24 hours',
      );
      expect(
        Time.tryParse('23:60:00'),
        null,
        reason: 'Should not allow 60 minutes',
      );
      expect(
        Time.tryParse('23:59:60'),
        null,
        reason: 'Should not allow 60 seconds',
      );
      expect(
        Time.tryParse('-1:00:00'),
        null,
        reason: 'Should not allow negative hours',
      );
      expect(
        Time.tryParse('abc'),
        null,
        reason: 'Should not allow non-numeric input',
      );
      expect(
        Time.tryParse('10:aa:00'),
        null,
        reason: 'Should not allow non-numeric components',
      );
      //TODO: decide what to do here
      // expect(
      //   Time.tryParse('10:00:'),
      //   null,
      //   reason: 'Should not allow trailing colon',
      // );
      expect(
        Time.tryParse(':10:00'),
        null,
        reason: 'Should not allow leading colon',
      );
      expect(
        Time.tryParse(''),
        null,
        reason: 'Should not allow empty string',
      );
    });
  });

  group('DateOnly and TimeOnly Integration', () {
    test('different times on same date are equal for DateOnly', () {
      final morning = DateTime(2024, 3, 20, 9);
      final afternoon = DateTime(2024, 3, 20, 14, 30);

      final dateOnlyMorning = Date(morning);
      final dateOnlyAfternoon = Date(afternoon);
      final timeOnlyMorning = Time(morning);
      final timeOnlyAfternoon = Time(afternoon);

      expect(dateOnlyMorning == dateOnlyAfternoon, true);
      expect(
        timeOnlyMorning.compareTo(timeOnlyAfternoon),
        -19800, // 5.5 hours in seconds
      );
    });

    test('same time on different dates are equal for TimeOnly', () {
      final today = DateTime(2024, 3, 20, 14, 30);
      final tomorrow = DateTime(2024, 3, 21, 14, 30);

      final dateOnlyToday = Date(today);
      final dateOnlyTomorrow = Date(tomorrow);
      final timeOnlyToday = Time(today);
      final timeOnlyTomorrow = Time(tomorrow);

      expect(dateOnlyToday == dateOnlyTomorrow, false);
      expect(
        timeOnlyToday.compareTo(timeOnlyTomorrow),
        0,
      );
    });

    test('handles daylight saving time transitions', () {
      // March 10, 2024 2:00 AM - Spring forward
      final beforeDST = DateTime(2024, 3, 10, 1, 59);
      final afterDST = DateTime(2024, 3, 10, 3);

      final dateOnlyBefore = Date(beforeDST);
      final dateOnlyAfter = Date(afterDST);
      final timeOnlyBefore = Time(beforeDST);
      final timeOnlyAfter = Time(afterDST);

      expect(dateOnlyBefore == dateOnlyAfter, true);
      expect(
        timeOnlyBefore.compareTo(timeOnlyAfter),
        -3660, // 1 hour and 1 minute difference in seconds
      );
    });
  });

  group('Zone-based time mocking', () {
    test('Date.today() can be mocked with zones', () {
      final mockDate = DateTime(2024, 3, 15);

      runZoned(
        () {
          final today = Date.today();
          expect(today.year, equals(2024));
          expect(today.month, equals(3));
          expect(today.day, equals(15));
        },
        zoneValues: {nowKey: () => mockDate},
      );
    });

    test('Time.now() can be mocked with zones', () {
      final mockTime = DateTime(2000, 1, 1, 14, 30, 15);

      runZoned(
        () {
          final now = Time.now();
          expect(now.hour, equals(14));
          expect(now.minute, equals(30));
          expect(now.second, equals(15));
        },
        zoneValues: {nowKey: () => mockTime},
      );
    });

    test('Date and Time can be mocked simultaneously', () {
      final mockDateTime = DateTime(2024, 3, 15, 14, 30, 15);

      runZoned(
        () {
          final today = Date.today();
          final now = Time.now();

          // Date assertions
          expect(today.year, equals(2024));
          expect(today.month, equals(3));
          expect(today.day, equals(15));

          // Time assertions
          expect(now.hour, equals(14));
          expect(now.minute, equals(30));
          expect(now.second, equals(15));
        },
        zoneValues: {nowKey: () => mockDateTime},
      );
    });

    test('Zone mocking does not affect other zones', () {
      final mockDateTime = DateTime(2024, 3, 15, 14, 30);
      final realNow = DateTime.now();

      // Run in a zone with mocked time
      runZoned(
        () {
          final mockedDate = Date.today();
          expect(mockedDate.year, equals(2024));
          expect(mockedDate.month, equals(3));
          expect(mockedDate.day, equals(15));
        },
        zoneValues: {nowKey: () => mockDateTime},
      );

      // Outside the zone should use real time
      final unmockedDate = Date.today();
      expect(unmockedDate.year, equals(realNow.year));
      expect(unmockedDate.month, equals(realNow.month));
      expect(unmockedDate.day, equals(realNow.day));
    });
  });
}
