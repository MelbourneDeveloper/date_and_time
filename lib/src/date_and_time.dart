import 'dart:async';

/// A key used in Zone values to provide custom DateTime implementations.
/// Any DateTime returned will be converted to UTC before use.
const nowKey = #CurrentDateKey;

/// A function type that provides the current DateTime.
typedef Now = DateTime Function();

/// Combines a [Date] and [Time] into a single [DateTime] instance.
/// The resulting [DateTime] will be in UTC. Note that [Date] and [Time]
/// instances are always in UTC internally, as they convert any input to UTC
/// during construction.
///
/// This is useful when you need to combine separate date and time components
/// into a single point in time.
///
/// Example:
/// ```dart
/// final date = Date.today();  // Creates UTC date
/// final time = Time.now();    // Creates UTC time
/// final dateTime = combineDateAndTime(date, time);  // Returns UTC DateTime
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
/// Note: you can mock the current time by setting the [nowKey] in the Zone to
/// a valid [Now] function that returns a UTC DateTime.
///
/// Example:
/// ```dart
/// final currentTime = now;  // Returns current UTC time
/// print(currentTime.isUtc);  // true
/// ```
DateTime get now => combineDateAndTime(Date.today(), Time.now());

/// Gets the current UTC date and time as an ISO 8601 string.
///
/// This is a convenience getter that returns the current UTC time
/// in ISO 8601 format with the 'Z' suffix indicating UTC.
///
/// Note: you can mock the current time by setting the [nowKey] in the Zone to
/// a valid [Now] function that returns a UTC DateTime.
///
/// Example:
/// ```dart
/// final currentTimeString = nowAsIso8601;  // "2024-03-20T14:30:00.000Z"
/// ```
String get nowAsIso8601 => now.toIso8601String();

/// Gets the current local date and time as a [DateTime].
///
/// This is a convenience getter that returns the current UTC time converted to
/// local time. Note that this converts from UTC to local time, so the date 
/// might change depending on the timezone offset.
///
/// Note: you can mock the current time by setting the [nowKey] in the Zone to
/// a valid [Now] function that returns a UTC DateTime.
///
/// Example:
/// ```dart
/// final localTime = nowLocal;  // Returns UTC time converted to local
/// print(localTime.isUtc);  // false
/// ```
DateTime get nowLocal => now.toLocal();

/// Gets the current local date and time as an ISO 8601 string.
///
/// This is a convenience getter that returns the current UTC time converted to
/// local time with the appropriate timezone offset in ISO 8601 format.
///
/// Note: you can mock the current time by setting the [nowKey] in the Zone to
/// a valid [Now] function that returns a UTC DateTime.
///
/// Example:
/// ```dart
/// final localTimeString = nowLocalAsIso8601;  // "2024-03-20T14:30:00.000+10:00"
/// ```
String get nowLocalAsIso8601 => nowLocal.toIso8601String();

/// An immutable type representing a calendar date without time components.
/// All dates are stored internally in UTC timezone. Any non-UTC input DateTime
/// will be converted to UTC during construction.
///
/// Note the behavior of extension types in Dart
/// (https://dart.dev/language/extension-types).
/// For most intends and purposes a [Date] is a [DateTime] but the time
/// component is not accessible. All operations are performed in UTC.
/// See the GitHub repo for a discussion on whether this type should be
/// a class or an extension type.
extension type Date._(DateTime _dateTime) {
  /// Creates a Date from a DateTime, stripping all time components and
  /// converting to UTC. If the input DateTime is not in UTC, it will be
  /// converted automatically.
  ///
  /// The resulting Date will be in UTC, regardless of the input DateTime's
  /// timezone.
  Date(DateTime dateTime)
      : _dateTime = dateTime.toUtc()._let(
              (dt) => DateTime.utc(
                dt.year,
                dt.month,
                dt.day,
              ),
            );

  /// Creates a Date from year, month, and day values. The resulting Date
  /// will be in UTC.
  Date.fromValues({required int year, required int month, required int day})
      : _dateTime = DateTime.utc(year, month, day);

  /// Creates a Date representing the current date in UTC, using Zone-provided
  /// time if available.
  ///
  /// Note: you can mock the current Date by setting the [nowKey] in the Zone to
  /// a valid [Now] function that returns a UTC DateTime.
  ///
  /// The resulting Date will always be in UTC.
  factory Date.today() => switch (Zone.current[nowKey]) {
        final Now now => Date(now().toUtc()),
        _ => Date(_utcNow),
      };

  /// Parses an ISO 8601 date string, returning null if the string is invalid.
  /// If the input string includes timezone information, it will be converted
  /// to UTC. The resulting Date will always be in UTC. 
  /// 
  /// ⚠️ you should always generate the ISO string using [toIso8601String] 
  /// because it includes the Z suffix to indicate UTC. If the string does
  /// not include the Z suffix, the date will be assumed to be in the local
  /// timezone, and will get converted to UTC.
  static Date? tryParse(String isoString) =>
      switch (DateTime.tryParse(isoString)) {
        final DateTime dateTime => Date(dateTime),
        _ => null
      };

  /// The minimum possible Date value (0001-01-01) in UTC
  static Date minValue = Date(DateTime.utc(1));

  /// The year component of the date in UTC
  int get year => _dateTime.year;

  /// The month component of the date (1-12) in UTC
  int get month => _dateTime.month;

  /// The day component of the date (1-31) in UTC
  int get day => _dateTime.day;

  /// Returns a new Date by subtracting the specified duration.
  /// The operation is performed in UTC.
  Date subtract(Duration duration) => Date(_dateTime.subtract(duration));

  /// Returns a new Date by adding the specified duration.
  /// The operation is performed in UTC.
  Date add(Duration duration) => Date(_dateTime.add(duration));

  /// The day of the week (1-7, where 1 is Monday) in UTC
  int get weekday => _dateTime.weekday;

  /// Converts this [Date] to an ISO 8601 DateTime string.
  /// The output will always represent UTC, and include the time component 
  /// (00:00:00). This is because the [Date] type is a wrapper around a 
  /// [DateTime], and the [DateTime] type includes the time component.
  String toIso8601String() => _dateTime.toIso8601String();

  /// Returns the underlying UTC [DateTime]. The time component will always be
  /// 00:00:00 UTC.
  DateTime get asDateTime => _dateTime;

  /// Returns the underlying UTC [DateTime] converted to local timezone.
  /// The time component will always be 00:00:00 in the local timezone.
  /// This is primarily used for display purposes.
  DateTime toLocalDateTime() => _dateTime.toLocal();
}

/// An immutable type representing a time of day without date components.
/// All times are stored internally in UTC timezone. Any non-UTC input DateTime
/// will be converted to UTC during construction.
///
/// Note the behavior of extension types in Dart
/// (https://dart.dev/language/extension-types).
/// For most intends and purposes a [Time] is a [DateTime] but the date
/// component is not accessible. All operations are performed in UTC.
/// See the GitHub repo for a discussion on whether this type should be
/// a class or an extension type.
extension type Time._(DateTime _dateTime) {
  /// Creates a Time from a DateTime, stripping all date components and
  /// converting to UTC. If the input DateTime is not in UTC, it will be
  /// converted automatically.
  ///
  /// The resulting Time will be in UTC, regardless of the input DateTime's
  /// timezone.
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

  /// Creates a [Time] from hour, minute, and optional second values. The 
  /// resulting [Time] will be in UTC.
  Time.fromValues({required int hour, required int minute, int second = 0})
      : _dateTime = DateTime.utc(0, 1, 1, hour, minute, second);

  /// Creates a Time representing the current time in UTC, using Zone-provided
  /// time if available.
  ///
  /// Note: you can mock the current Time by setting the [nowKey] in the Zone to
  /// a valid [Now] function that returns a UTC DateTime.
  ///
  /// The resulting Time will always be in UTC.
  factory Time.now() => switch (Zone.current[nowKey]) {
        final Now now => Time(now().toUtc()),
        _ => Time(_utcNow),
      };

  /// Parses a time string in the format "HH:mm" or "HH:mm:ss", returning null 
  /// if invalid. The input is assumed to be in UTC. If timezone 
  /// information is provided, it will be converted to UTC.
  ///
  /// Example:
  /// ```dart
  /// final utcTime = Time.tryParse('14:30:00');  // Parsed as UTC
  /// final tzTime = Time.tryParse('14:30:00+02:00');  // Converted to UTC
  /// ```
  static Time? tryParse(String timeString) {
    final time = timeString.split(':');

    if (time.length < 2 || time.length > 3) {
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
              when _isValid(hour, minute, 0) && time.length == 2 =>
            Time.fromValues(
              hour: hour,
              minute: minute,
            ),
          _ => null,
        },
    };
  }

  /// Validates if the given hour, minute, and second values represent a valid 
  /// UTC time
  static bool _isValid(int hour, int minute, int second) =>
      hour >= 0 &&
      hour < 24 &&
      minute >= 0 &&
      minute < 60 &&
      second >= 0 &&
      second < 60;

  /// The hour component of the time (0-23) in UTC
  int get hour => _dateTime.hour;

  /// The minute component of the time (0-59) in UTC
  int get minute => _dateTime.minute;

  /// The second component of the time (0-59) in UTC
  int get second => _dateTime.second;

  /// Total number of seconds since midnight in UTC
  int get totalSeconds => hour * 3600 + minute * 60 + second;

  /// Compares two Time values in UTC, returning:
  /// * negative if this time is earlier than other
  /// * positive if this time is later than other
  /// * zero if the times are equal
  ///
  /// Both times are compared in UTC, ensuring consistent results across 
  /// timezones.
  int compareTo(Time other) => totalSeconds - other.totalSeconds;

  /// Converts this Time to an ISO 8601 string.
  /// The output represents the time in UTC without timezone information.
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
