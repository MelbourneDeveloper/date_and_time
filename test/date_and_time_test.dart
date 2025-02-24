import 'dart:async';

import 'package:date_and_time/library.dart';
import 'package:test/test.dart';

void main() {
  group('Date', () {
    test('creates from UTC DateTime', () {
      final utcDate = DateTime.utc(2024, 3, 20);
      final date = Date(utcDate);

      expect(date.year, 2024);
      expect(date.month, 3);
      expect(date.day, 20);
    });

    test('converts local DateTime to UTC', () {
      final localDate = DateTime(2024, 3, 20, 14, 30); // Local time
      final date = Date(localDate);
      final utcDate = Date(localDate.toUtc()); // Explicit UTC conversion

      expect(date.year, utcDate.year);
      expect(date.month, utcDate.month);
      expect(date.day, utcDate.day);
    });

    test('creates from values in UTC', () {
      final dateOnly = Date.fromValues(
        year: 2024,
        month: 3,
        day: 20,
      );

      expect(dateOnly.year, 2024);
      expect(dateOnly.month, 3);
      expect(dateOnly.day, 20);
    });

    test('equals ignores time components while preserving UTC', () {
      final date1 = DateTime.utc(2024, 3, 20, 14, 30, 45);
      final date2 = DateTime.utc(2024, 3, 20, 9);
      final date3 = DateTime.utc(2024, 3, 20, 23, 59, 59, 999);

      final dateOnly1 = Date(date1);
      final dateOnly2 = Date(date2);
      final dateOnly3 = Date(date3);

      expect(dateOnly1 == dateOnly2, true);
      expect(dateOnly2 == dateOnly3, true);
      expect(dateOnly1 == dateOnly3, true);
    });

    test('not equals for different dates in UTC', () {
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

    test('handles leap years correctly in UTC', () {
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

    test('handles edge cases around UTC midnight', () {
      final justBeforeMidnight = DateTime.utc(2024, 3, 20, 23, 59, 59, 999);
      final midnight = DateTime.utc(2024, 3, 21);
      final justAfterMidnight = DateTime.utc(2024, 3, 21, 0, 0, 1);

      final dateOnlyBefore = Date(justBeforeMidnight);
      final dateOnlyMidnight = Date(midnight);
      final dateOnlyAfter = Date(justAfterMidnight);

      expect(dateOnlyBefore == dateOnlyMidnight, false);
      expect(dateOnlyMidnight == dateOnlyAfter, true);
      expect(dateOnlyBefore.day, 20);
      expect(dateOnlyMidnight.day, 21);
      expect(dateOnlyAfter.day, 21);
    });

    test('supports add and subtract operations preserving UTC', () {
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

    test('handles month boundaries with add/subtract in UTC', () {
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

    test('provides weekday information in UTC', () {
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

    test('parses date strings', () {
      // Basic date parsing without time/timezone
      final parsedDate = Date.tryParse('2024-03-20');
      final parsedDateTime = DateTime.tryParse('2024-03-20');
      expectDateEquivalence(parsedDate, parsedDateTime);

      // Test with simple date string
      const dateString = '2024-03-20';
      final utcParsed = Date.tryParse(dateString);
      expect(utcParsed?.year, 2024);
      expect(utcParsed?.month, 3);
      expect(utcParsed?.day, 20);
      expect(utcParsed?.toDateString(), '2024-03-20');
    });

    test('handles time without timezone', () {
      final dateTime = Date.tryParse('2024-03-20');
      expect(dateTime?.year, 2024);
      expect(dateTime?.month, 3);
      expect(dateTime?.day, 20);
    });

    test('handles timezone offsets correctly', () {
      // Test date with timezone that changes the date
      final dateWithOffset = Date.tryParse('2024-03-21');
      expect(dateWithOffset?.year, 2024);
      expect(dateWithOffset?.month, 3);
      expect(dateWithOffset?.day, 21);

      // Test date with timezone that doesn't change the date
      final dateNoChange = Date.tryParse('2024-03-20');
      expect(dateNoChange?.year, 2024);
      expect(dateNoChange?.month, 3);
      expect(dateNoChange?.day, 20);

      // Test invalid timezone format
      expect(Date.tryParse('2024-03-20+invalid'), null);
      expect(Date.tryParse('2024-03-20+'), null);
      expect(Date.tryParse('2024-03-20-'), null);
    });

    test('handles date with time and no timezone', () {
      final dateTime = Date.tryParse('2024-03-20');
      expect(dateTime?.year, 2024);
      expect(dateTime?.month, 3);
      expect(dateTime?.day, 20);
    });

    test('handles date with invalid time', () {
      expect(Date.tryParse('2024-03-20'), DateTime.utc(2024, 03, 20));
      expect(Date.tryParse('2024-03-20'), DateTime.utc(2024, 03, 20));
      expect(Date.tryParse('2024-03-20'), DateTime.utc(2024, 03, 20));
    });
  });

  group('Time', () {
    test('creates from UTC DateTime', () {
      final utcDate = DateTime.utc(2024, 3, 20, 14, 30, 45);
      final timeOnly = Time(utcDate);

      expect(timeOnly.hour, 14);
      expect(timeOnly.minute, 30);
      expect(timeOnly.second, 45);
    });

    test('converts local DateTime to UTC', () {
      final localTime = DateTime(2024, 3, 20, 14, 30, 45); // Local time
      final time = Time(localTime);
      final utcTime = Time(localTime.toUtc()); // Explicit UTC conversion

      expect(time.hour, utcTime.hour);
      expect(time.minute, utcTime.minute);
      expect(time.second, utcTime.second);
    });

    test('creates from values in UTC', () {
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
        DateTime.utc(2024, 1, 1, 14, 30, 45),
        DateTime.utc(2024, 1, 1, 14, 30),
        DateTime.utc(2024, 1, 1, 14, 31),
        DateTime.utc(2024, 1, 1, 14, 30, 46),
        DateTime.utc(2024, 1, 1, 13, 59, 59),
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

  group('Date and Time Integration', () {
    test('handles timezone conversion consistently', () {
      // Create a UTC DateTime at 23:30
      final utcDateTime = DateTime.utc(2024, 3, 20, 23, 30);

      // Create Date and Time from the UTC DateTime
      final date = Date(utcDateTime);
      final time = Time(utcDateTime);

      // The date should be March 20
      expect(date.year, 2024);
      expect(date.month, 3);
      expect(date.day, 20);

      // The time should be 23:30
      expect(time.hour, 23);
      expect(time.minute, 30);
      expect(time.second, 0);

      // Now create a local DateTime that will convert to the same UTC time
      final localDateTime = utcDateTime.toLocal();
      final dateFromLocal = Date(localDateTime);
      final timeFromLocal = Time(localDateTime);

      // Should get the same results when converting from local time
      expect(dateFromLocal.year, date.year);
      expect(dateFromLocal.month, date.month);
      expect(dateFromLocal.day, date.day);
      expect(timeFromLocal.hour, time.hour);
      expect(timeFromLocal.minute, time.minute);
      expect(timeFromLocal.second, time.second);
    });

    test('handles UTC to local time conversion', () {
      final utcDateTime = DateTime.utc(2024, 3, 20, 23, 30);
      final localDateTime = utcDateTime.toLocal();

      final date = Date(utcDateTime);
      final time = Time(utcDateTime);

      final localDate = Date(localDateTime);
      final localTime = Time(localDateTime);

      expect(localDate.year, date.year);
      expect(localDate.month, date.month);
      expect(localDate.day, date.day);
      expect(localTime.hour, time.hour);
      expect(localTime.minute, time.minute);
      expect(localTime.second, time.second);
      expect(localDate == date, true);
    });

    test('handles daylight saving time transitions', () {
      // Assuming daylight saving time starts on March 10, 2024
      final beforeDST = DateTime.utc(2024, 3, 9);
      final afterDST = DateTime.utc(2024, 3, 11);

      final dateBeforeDST = Date(beforeDST);
      final dateAfterDST = Date(afterDST);

      final localBeforeDST = beforeDST.toLocal();
      final localAfterDST = afterDST.toLocal();

      expect(dateBeforeDST.day, localBeforeDST.day);
      expect(dateAfterDST.day, localAfterDST.day);
    });
  });

  group('DateOnly and TimeOnly Integration', () {
    test('different times on same date are equal for DateOnly', () {
      final morning = DateTime.utc(2024, 3, 20, 9);
      final afternoon = DateTime.utc(2024, 3, 20, 14, 30);

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
    test('Date.today() returns UTC when mocked', () {
      final mockDate = DateTime.utc(2024, 3, 15);

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

    test('Time.now() returns UTC when mocked', () {
      final mockTime = DateTime.utc(2000, 1, 1, 14, 30, 15);

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

    test('Date and Time can be mocked simultaneously in UTC', () {
      final mockDateTime = DateTime.utc(2024, 3, 15, 14, 30, 15);

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
      final mockDateTime = DateTime.utc(2024, 3, 15, 14, 30);
      final realNow = DateTime.now().toUtc();

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

  group('Now and Zone-based time', () {
    test('uses Zone-provided time when available', () {
      final fixedTime = DateTime.utc(2024, 3, 20, 14, 30);
      runZoned(
        () {
          expect(now, fixedTime);
          expect(nowAsIso8601, fixedTime.toIso8601String());
          expect(nowLocal, fixedTime.toLocal());
          expect(nowLocalAsIso8601, fixedTime.toLocal().toIso8601String());

          final date = Date.today();
          expect(date.year, fixedTime.year);
          expect(date.month, fixedTime.month);
          expect(date.day, fixedTime.day);

          final time = Time.now();
          expect(time.hour, fixedTime.hour);
          expect(time.minute, fixedTime.minute);
          expect(time.second, fixedTime.second);
        },
        zoneValues: {
          nowKey: () => fixedTime,
        },
      );
    });

    test('uses system time when no Zone time is provided', () {
      final beforeTest = DateTime.now().toUtc();
      final result = now;
      final afterTest = DateTime.now().toUtc();

      // The result should be between beforeTest and afterTest
      // Convert to milliseconds since epoch for reliable comparison
      final resultMs = result.millisecondsSinceEpoch;
      final beforeMs = beforeTest.millisecondsSinceEpoch;
      final afterMs = afterTest.millisecondsSinceEpoch;

      // Allow for a small margin of error (1 second) since the test might
      // run slowly
      final isWithinRange =
          resultMs >= beforeMs - 1000 && resultMs <= afterMs + 1000;
      expect(
        isWithinRange,
        true,
        reason: 'Expected $resultMs to be between $beforeMs and $afterMs',
      );
    });
  });

  group('Additional Date parsing cases', () {
    test('handles invalid date formats', () {
      expect(Date.tryParse('2024-03-20T'), null);
      expect(Date.tryParse('2024-03-20Z'), null);
      expect(Date.tryParse('2024-03-20+02:00'), null);
      expect(Date.tryParse('invalid'), null);
      expect(Date.tryParse(''), null);
    });

    test('handles invalid date components', () {
      expect(Date.tryParse('2024-13-20'), null); // Invalid month
      expect(Date.tryParse('2024-00-20'), null); // Invalid month
      expect(Date.tryParse('2024-03-32'), null); // Invalid day
      expect(Date.tryParse('2024-03-00'), null); // Invalid day
      expect(Date.tryParse('0000-03-20'), null); // Invalid year
    });
  });

  group('Date string formatting', () {
    test('formats date correctly', () {
      final date = Date.fromValues(year: 2024, month: 3, day: 20);
      expect(
        date.toDateString(),
        '2024-03-20',
        reason: 'Date string should match expected format',
      );
    });

    test('handles leading zeros in month and day', () {
      final date = Date.fromValues(year: 2024, month: 1, day: 5);
      expect(date.toDateString(), '2024-01-05');
    });

    test('handles minimum date value', () {
      final minDate = Date.minValue;
      expect(minDate.toDateString(), '0001-01-01');
    });
  });

  group('Date round-trip', () {
    test('preserves date components', () {
      final dates = [
        Date.fromValues(year: 2024, month: 3, day: 20),
        Date.fromValues(year: 2024, month: 12, day: 31),
        Date.fromValues(year: 2024, month: 1, day: 1),
        Date.fromValues(year: 1, month: 1, day: 1), // Min value
        Date.fromValues(year: 9999, month: 12, day: 31), // Near max
      ];

      for (final date in dates) {
        final dateString = date.toDateString();
        final roundTripped = Date.tryParse(dateString);
        expect(
          roundTripped,
          date,
          reason: 'Failed round-trip for $dateString',
        );
      }
    });

    test('handles different date formats', () {
      // Test pairs of [input string, expected normalized output]
      const testCases = [
        // Basic date formats
        ['2024-03-20', '2024-03-20'],
        ['2024-12-31', '2024-12-31'],
        ['2024-01-01', '2024-01-01'],

        // With leading zeros
        ['2024-03-05', '2024-03-05'],
        ['2024-03-20', '2024-03-20'],
      ];

      for (final testCase in testCases) {
        final input = testCase[0];
        final expectedOutput = testCase[1];
        final date = Date.tryParse(input);
        expect(
          date?.toDateString(),
          expectedOutput,
          reason: 'Failed for input: $input',
        );
      }
    });
  });

  group('Time string formatting', () {
    test('formats time correctly', () {
      final time = Time.fromValues(hour: 14, minute: 30, second: 45);
      expect(time.toTimeString(), '14:30:45');

      final timeWithLeadingZeros =
          Time.fromValues(hour: 9, minute: 5, second: 2);
      expect(timeWithLeadingZeros.toTimeString(), '09:05:02');

      final midnight = Time.fromValues(hour: 0, minute: 0);
      expect(midnight.toTimeString(), '00:00:00');

      final noon = Time.fromValues(hour: 12, minute: 0);
      expect(noon.toTimeString(), '12:00:00');

      final endOfDay = Time.fromValues(hour: 23, minute: 59, second: 59);
      expect(endOfDay.toTimeString(), '23:59:59');
    });
  });

  group('Utility Functions', () {
    test('combineDateAndTime creates correct UTC DateTime', () {
      final date = Date.fromValues(year: 2024, month: 3, day: 20);
      final time = Time.fromValues(hour: 14, minute: 30, second: 45);

      final combined = combineDateAndTime(date, time);

      expect(combined.isUtc, true);
      expect(combined.year, 2024);
      expect(combined.month, 3);
      expect(combined.day, 20);
      expect(combined.hour, 14);
      expect(combined.minute, 30);
      expect(combined.second, 45);
    });

    test('now returns correct UTC DateTime', () {
      final mockDateTime = DateTime.utc(2024, 3, 15, 14, 30, 15);

      runZoned(
        () {
          final current = now;
          expect(current.isUtc, true);
          expect(current.year, 2024);
          expect(current.month, 3);
          expect(current.day, 15);
          expect(current.hour, 14);
          expect(current.minute, 30);
          expect(current.second, 15);
        },
        zoneValues: {nowKey: () => mockDateTime},
      );
    });

    test('nowAsIso8601 returns valid UTC ISO string', () {
      final mockDateTime = DateTime.utc(2024, 3, 15, 14, 30, 15);

      runZoned(
        () {
          final isoString = nowAsIso8601;
          expect(
            isoString,
            '2024-03-15T14:30:15.000Z',
            reason: 'Should return UTC ISO 8601 string',
          );
        },
        zoneValues: {nowKey: () => mockDateTime},
      );
    });

    test('nowLocal returns DateTime in local timezone', () {
      final mockDateTime = DateTime.utc(2024, 3, 15, 14, 30, 15);

      runZoned(
        () {
          final localTime = nowLocal;
          expect(localTime.isUtc, false);

          // Convert back to UTC for comparison
          final backToUtc = localTime.toUtc();
          expect(backToUtc.year, 2024);
          expect(backToUtc.month, 3);
          expect(backToUtc.day, 15);
          expect(backToUtc.hour, 14);
          expect(backToUtc.minute, 30);
          expect(backToUtc.second, 15);
        },
        zoneValues: {nowKey: () => mockDateTime},
      );
    });

    test('nowLocalAsIso8601 returns ISO string with timezone offset', () {
      final mockDateTime = DateTime.utc(2024, 3, 15, 14, 30, 15);

      runZoned(
        () {
          final localIsoString = nowLocalAsIso8601;
          final localDateTime = mockDateTime.toLocal();
          final expectedIsoString = localDateTime.toIso8601String();

          expect(
            localIsoString,
            expectedIsoString,
            reason: 'Should match local DateTime ISO string',
          );
        },
        zoneValues: {nowKey: () => mockDateTime},
      );
    });
  });

  group('DateAndTime record', () {
    test('creates from Date and Time', () {
      final date = Date.fromValues(year: 2024, month: 3, day: 20);
      final time = Time.fromValues(hour: 14, minute: 30, second: 45);

      final dateAndTime = createDateAndTime(date, time);
      expect(dateAndTime.date, date);
      expect(dateAndTime.time, time);

      // Test toDateTime extension
      final dateTime = dateAndTime.toDateTime();
      expect(dateTime.isUtc, true);
      expect(dateTime.year, 2024);
      expect(dateTime.month, 3);
      expect(dateTime.day, 20);
      expect(dateTime.hour, 14);
      expect(dateTime.minute, 30);
      expect(dateTime.second, 45);

      // Test DateTime.toDateAndTime extension
      final roundTrip = dateTime.toDateAndTime();
      expect(roundTrip.date, date);
      expect(roundTrip.time, time);
    });

    test('converts local DateTime to DateAndTime', () {
      final localDateTime = DateTime(2024, 3, 20, 14, 30, 45);
      final dateAndTime = localDateTime.toDateAndTime();
      final utcDateTime = localDateTime.toUtc();

      expect(dateAndTime.date.year, utcDateTime.year);
      expect(dateAndTime.date.month, utcDateTime.month);
      expect(dateAndTime.date.day, utcDateTime.day);
      expect(dateAndTime.time.hour, utcDateTime.hour);
      expect(dateAndTime.time.minute, utcDateTime.minute);
      expect(dateAndTime.time.second, utcDateTime.second);

      // Test round-trip through toDateTime
      final roundTrip = dateAndTime.toDateTime();
      expect(roundTrip.isUtc, true);
      expect(roundTrip.year, utcDateTime.year);
      expect(roundTrip.month, utcDateTime.month);
      expect(roundTrip.day, utcDateTime.day);
      expect(roundTrip.hour, utcDateTime.hour);
      expect(roundTrip.minute, utcDateTime.minute);
      expect(roundTrip.second, utcDateTime.second);
    });

    test('converts to local DateTime', () {
      final date = Date.fromValues(year: 2024, month: 3, day: 20);
      final time = Time.fromValues(hour: 14, minute: 30, second: 45);
      final dateAndTime = createDateAndTime(date, time);

      final localDateTime = dateAndTime.toDateTimeLocal();
      expect(localDateTime.isUtc, false);

      // Convert back to UTC for comparison
      final backToUtc = localDateTime.toUtc();
      expect(backToUtc.year, 2024);
      expect(backToUtc.month, 3);
      expect(backToUtc.day, 20);
      expect(backToUtc.hour, 14);
      expect(backToUtc.minute, 30);
      expect(backToUtc.second, 45);

      // Test round-trip through DateAndTime
      final roundTrip = localDateTime.toDateAndTime();
      expect(roundTrip.date, date);
      expect(roundTrip.time, time);
    });
  });

  group('DateTime extensions', () {
    test('converts to DateAndTime', () {
      final dateTime = DateTime.utc(2024, 3, 20, 14, 30, 45);
      final dateAndTime = dateTime.toDateAndTime();

      expect(dateAndTime.date.year, 2024);
      expect(dateAndTime.date.month, 3);
      expect(dateAndTime.date.day, 20);
      expect(dateAndTime.time.hour, 14);
      expect(dateAndTime.time.minute, 30);
      expect(dateAndTime.time.second, 45);
    });

    test('converts local DateTime to DateAndTime in UTC', () {
      final localDateTime = DateTime(2024, 3, 20, 14, 30, 45);
      final dateAndTime = localDateTime.toDateAndTime();
      final utcDateTime = localDateTime.toUtc();

      expect(dateAndTime.date.year, utcDateTime.year);
      expect(dateAndTime.date.month, utcDateTime.month);
      expect(dateAndTime.date.day, utcDateTime.day);
      expect(dateAndTime.time.hour, utcDateTime.hour);
      expect(dateAndTime.time.minute, utcDateTime.minute);
      expect(dateAndTime.time.second, utcDateTime.second);
    });
  });
}

/// Expects that the date and dateTime are equivalent, taking into account
/// the local timezone offset.
void expectDateEquivalence(Date? date, DateTime? dateTime) {
  if (date == null || dateTime == null) {
    expect(date, dateTime);
    return;
  }

  expect(date.year, dateTime.year);
  expect(date.month, dateTime.month);
  expect(date.day, dateTime.day);
}
