import 'dart:async';

/// A key used in Zone values to provide custom DateTime implementations
const nowKey = #CurrentDateKey;

/// A function type that provides the current DateTime
typedef Now = DateTime Function();

/// Combines a [Date] and [Time] into a single [DateTime] instance.
/// The resulting [DateTime] will be in UTC.
///
/// This is useful when you need to combine separate date and time components
/// into a single point in time.
///
/// Example:
/// ```dart
/// final date = Date.today();
/// final time = Time.now();
/// final dateTime = combineDateAndTime(date, time);
/// ```
DateTime combineDateAndTime(Date date, Time time) => DateTime.utc(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
      time.second,
    );

/// Gets the current UTC date and time as a [DateTime].
///
/// This is a convenience getter that combines [Date.today()] and [Time.now()]
/// into a single [DateTime]. The result is always in UTC.
///
/// Example:
/// ```dart
/// final currentTime = now; // Returns current UTC time
/// ```
DateTime get now => combineDateAndTime(Date.today(), Time.now());

/// Gets the current UTC date and time as an ISO 8601 string.
///
/// This is a convenience getter that returns the current UTC time
/// in ISO 8601 format with the 'Z' suffix indicating UTC.
///
/// Note: you can mock the current time by setting the [nowKey] in the Zone to
/// a valid [Now] function.
///
/// Example:
/// ```dart
/// final currentTimeString = nowAsIso8601; // "2024-03-20T14:30:00.000Z"
/// ```
String get nowAsIso8601 => now.toIso8601String();

/// Gets the current local date and time as a [DateTime].
///
/// This is a convenience getter that returns the current time in the local
/// timezone. Note that this converts from UTC to local time, so the date might
/// change depending on the timezone offset.
/// 
/// Note: you can mock the current time by setting the [nowKey] in the Zone to
/// a valid [Now] function.
///
/// Example:
/// ```dart
/// final localTime = nowLocal; // Returns current local time
/// ```
DateTime get nowLocal => now.toLocal();

/// Gets the current local date and time as an ISO 8601 string.
///
/// This is a convenience getter that returns the current time in the local
/// timezone with the appropriate timezone offset.
///
/// Note: you can mock the current time by setting the [nowKey] in the Zone to
/// a valid [Now] function.
///
/// Example:
/// ```dart
/// final localTimeString = nowLocalAsIso8601; // "2024-03-20T14:30:00.000+10:00"
/// ```
String get nowLocalAsIso8601 => nowLocal.toIso8601String();

/// An immutable type representing a calendar date without time components.
/// Note the behavior of extension types in Dart (https://dart.dev/language/extension-types).
/// For most intends and purposes a [Date] is a [DateTime] but the time
/// component is not accessible. See the GitHub repo for a discussion on whether
/// this type should be a class or an extension type.
extension type Date._(DateTime _dateTime) {
  /// Creates a Date from a DateTime, stripping all time components and
  /// converting to UTC
  Date(DateTime dateTime)
      : _dateTime = dateTime.toUtc()._let(
              (dt) => DateTime.utc(
                dt.year,
                dt.month,
                dt.day,
              ),
            );

  /// Creates a Date from explicit year, month, and day values in UTC
  Date.fromValues({required int year, required int month, required int day})
      : _dateTime = DateTime.utc(year, month, day);

  /// Creates a Date representing the current date in UTC, using Zone-provided
  /// time if available
  /// 
  /// Note: you can mock the current Date/Time by setting the [nowKey] in the Zone to
  /// a valid [Now] function. 
  factory Date.today() => switch (Zone.current[nowKey]) {
        final Now now => Date(now().toUtc()),
        _ => Date(_utcNow),
      };

  /// Parses an ISO 8601 date string, returning null if the string is invalid
  /// The resulting Date will be in UTC
  static Date? tryParse(String isoString) {
    // If the string doesn't contain time information, treat it as UTC
    if (!isoString.contains('T')) {
      return switch (DateTime.tryParse('${isoString}T00:00:00Z')) {
        final DateTime dateTime => Date(dateTime),
        _ => null
      };
    }

    // If it has time information but no timezone, assume UTC
    if (!isoString.contains('Z') &&
        !isoString.contains('+') &&
        !isoString.contains('-')) {
      return switch (DateTime.tryParse('${isoString}Z')) {
        final DateTime dateTime => Date(dateTime),
        _ => null
      };
    }

    // Otherwise parse with timezone information
    return switch (DateTime.tryParse(isoString)) {
      final DateTime dateTime => Date(dateTime),
      _ => null
    };
  }

  /// The minimum possible Date value (0001-01-01) in UTC
  static Date minValue = Date(DateTime.utc(1));

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
/// Note the behavior of extension types in Dart (https://dart.dev/language/extension-types).
/// For most intends and purposes a [Time] is a [DateTime] but the date
/// component is not accessible. See the GitHub repo for a discussion on whether
/// this type should be a class or an extension type.
extension type Time._(DateTime _dateTime) {
  /// Creates a Time from a DateTime, stripping all date components and
  /// converting to UTC
  Time(DateTime dateTime)
      : _dateTime = dateTime.toUtc()._let(
              (dt) => DateTime.utc(
                0,
                1,
                1,
                dt.hour,
                dt.minute,
                dt.second,
              ),
            );

  /// Creates a Time from explicit hour, minute, and optional second values in
  /// UTC
  Time.fromValues({required int hour, required int minute, int second = 0})
      : _dateTime = DateTime.utc(0, 1, 1, hour, minute, second);

  /// Creates a Time representing the current time in UTC, using Zone-provided
  /// time if available
  ///
  /// Note: you can mock the current Date/Time by setting the [nowKey] in the Zone to
  /// a valid [Now] function. 
  factory Time.now() => switch (Zone.current[nowKey]) {
        final Now now => Time(now().toUtc()),
        _ => Time(_utcNow),
      };

  /// Like this 13:01:00
  static Time? tryParse(String timeString) {
    final time = timeString.split(':');

    if (time.length < 2) {
      return null;
    }

    final time3 = time.length > 2 ? time[2] : null;

    return switch ((time[0], time[1], time3)) {
      (
        final String hour,
        final String minute,
        final String? second,
      ) =>
        switch ((
          int.tryParse(hour),
          int.tryParse(minute),
          second != null ? int.tryParse(second) : null,
        )) {
          (final int hour, final int minute, final int second)
              when _isValid(hour, minute, second) =>
            Time.fromValues(
              hour: hour,
              minute: minute,
              second: second,
            ),
          (final int hour, final int minute, final int second)
              when !_isValid(hour, minute, second) =>
            null,
          (final int hour, final int minute, _)
              when _isValid(hour, minute, 0) =>
            Time.fromValues(
              hour: hour,
              minute: minute,
            ),
          _ => null,
        },
    };
  }

  static bool _isValid(int hour, int minute, int second) =>
      hour >= 0 &&
      hour < 24 &&
      minute >= 0 &&
      minute < 60 &&
      second >= 0 &&
      second < 60;

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
  String toIso8601String() => '${hour.toString().padLeft(2, '0')}:'
      '${minute.toString().padLeft(2, '0')}:'
      '${second.toString().padLeft(2, '0')}';
}

/// Convenience extensions, not to be exported
extension _ObjectExtensions<T> on T {
  R _let<R>(R Function(T it) f) => f(this);
}

/// Convenience getter for the current UTC DateTime
DateTime get _utcNow => DateTime.now().toUtc();
