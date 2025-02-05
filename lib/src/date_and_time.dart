import 'dart:async';

/// A key used in Zone values to provide custom DateTime implementations
const nowKey = #CurrentDateKey;

/// A function type that provides the current DateTime
typedef Now = DateTime Function();

/// An immutable type representing a calendar date without time components
extension type Date._(DateTime _dateTime) {
  /// Creates a Date from a DateTime, stripping all time components
  Date(DateTime dateTime)
      : _dateTime = DateTime(dateTime.year, dateTime.month, dateTime.day);

  /// Creates a Date from explicit year, month, and day values
  Date.fromValues({required int year, required int month, required int day})
      : _dateTime = DateTime(year, month, day);

  /// Creates a Date representing the current date, using Zone-provided time if
  /// available
  factory Date.today() => switch (Zone.current[nowKey]) {
        final Now now => Date(now()),
        _ => Date(DateTime.now()),
      };

  /// Parses an ISO 8601 date string, returning null if the string is invalid
  static Date? tryParse(String isoString) =>
      switch (DateTime.tryParse(isoString)) {
        final DateTime dateTime => Date(dateTime),
        _ => null
      };

  /// The minimum possible Date value (0001-01-01)
  static Date minValue = Date(DateTime(1));

  /// The year component of the date
  int get year => _dateTime.year;

  /// The month component of the date (1-12)
  int get month => _dateTime.month;

  /// The day component of the date (1-31)
  int get day => _dateTime.day;

  /// Returns a new Date by subtracting the specified duration
  Date subtract(Duration duration) => Date(_dateTime.subtract(duration));

  /// Returns a new Date by adding the specified duration
  Date add(Duration duration) => Date(_dateTime.add(duration));

  /// The day of the week (1-7, where 1 is Monday)
  int get weekday => _dateTime.weekday;

  /// Converts this Date to an ISO 8601 string
  String toIso8601String() =>
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}'
      '-${day.toString().padLeft(2, '0')}';
}

/// An immutable type representing a time of day without date components
extension type Time._(DateTime _dateTime) {
  /// Creates a Time from a DateTime, stripping all date components
  Time(DateTime dateTime)
      : _dateTime =
            DateTime(0, 1, 1, dateTime.hour, dateTime.minute, dateTime.second);

  /// Creates a Time from explicit hour, minute, and optional second values
  Time.fromValues({required int hour, required int minute, int second = 0})
      : _dateTime = DateTime(0, 1, 1, hour, minute, second);

  /// Creates a Time representing the current time, using Zone-provided time 
  /// if available
  factory Time.now() => switch (Zone.current[nowKey]) {
        final Now now => Time(now()),
        _ => Time(DateTime.now()),
      };

  /// Like this 10:01:00
  static Time? tryParse(String timeString) {
    final time = timeString.split(':');

    if (time.length < 2) {
      return null;
    }

    return switch ((time[0], time[1], time[2])) {
      (
        final String hour,
        final String minute,
        final String second,
      ) =>
        switch ((
          int.tryParse(hour),
          int.tryParse(minute),
          int.tryParse(second)
        )) {
          (final int hour, final int minute, final int second) =>
            Time.fromValues(
              hour: hour,
              minute: minute,
              second: second,
            ),
          (final int hour, final int minute, _) => Time.fromValues(
              hour: hour,
              minute: minute,
            ),
          _ => null,
        },
    };
  }

  /// The hour component of the time (0-23)
  int get hour => _dateTime.hour;

  /// The minute component of the time (0-59)
  int get minute => _dateTime.minute;

  /// The second component of the time (0-59)
  int get second => _dateTime.second;

  /// Total number of seconds since midnight
  int get totalSeconds => hour * 3600 + minute * 60 + second;

  /// Compares two Time values, returning:
  /// * negative if this time is earlier than other
  /// * positive if this time is later than other
  /// * zero if the times are equal
  int compareTo(Time other) => totalSeconds - other.totalSeconds;

  /// Converts this Time to an ISO 8601 string
  String toIso8601String() =>
      '${hour.toString().padLeft(2, '0')}:'
      '${minute.toString().padLeft(2, '0')}:'
      '${second.toString().padLeft(2, '0')}';
}
