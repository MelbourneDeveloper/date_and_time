
import 'dart:io';

import 'package:date_and_time/library.dart';

void main() {
  print('Date and Time Types Demo\n');

  // Demonstrate Date operations
  demonstrateDateOperations();

  print('\n-------------------\n');

  // Demonstrate Time operations
  demonstrateTimeOperations();
}

void demonstrateDateOperations() {
  print('Date Operations:');
  print('---------------');

  // Show today's date
  final today = Date.today();
  print('Today is: ${today.toIso8601String()}');

  // Get user input for a date
  print('\nEnter a date (YYYY-MM-DD):');
  final input = stdin.readLineSync();

  final userDate = Date.tryParse(input ?? '');
  if (userDate == null) {
    print('Invalid date format. Please use YYYY-MM-DD');
    return;
  }

  print('You entered: ${userDate.toIso8601String()}');
  print('Year: ${userDate.year}');
  print('Month: ${userDate.month}');
  print('Day: ${userDate.day}');
  print('Weekday: ${_getWeekdayName(userDate.weekday)}');

  // Demonstrate date arithmetic
  final tomorrow = userDate.add(const Duration(days: 1));
  final yesterday = userDate.subtract(const Duration(days: 1));

  print('\nTomorrow will be: ${tomorrow.toIso8601String()}');
  print('Yesterday was: ${yesterday.toIso8601String()}');
}

void demonstrateTimeOperations() {
  print('Time Operations:');
  print('---------------');

  // Show current time
  final now = Time.now();
  print('Current time is: ${now.toIso8601String()}');

  // Get user input for a time
  print('\nEnter a time (HH:MM:SS or HH:MM):');
  final input = stdin.readLineSync();

  final userTime = Time.tryParse(input ?? '');
  if (userTime == null) {
    print('Invalid time format. Please use HH:MM:SS or HH:MM');
    return;
  }

  print('You entered: ${userTime.toIso8601String()}');
  print('Hour: ${userTime.hour}');
  print('Minute: ${userTime.minute}');
  print('Second: ${userTime.second}');
  print('Total seconds since midnight: ${userTime.totalSeconds}');

  // Demonstrate time comparison
  final comparison = userTime.compareTo(now);
  final relationToNow = switch (comparison) {
    < 0 => 'earlier than',
    > 0 => 'later than',
    _ => 'the same as'
  };

  print('\nYour time is $relationToNow the current time');
}

String _getWeekdayName(int weekday) => switch (weekday) {
      1 => 'Monday',
      2 => 'Tuesday',
      3 => 'Wednesday',
      4 => 'Thursday',
      5 => 'Friday',
      6 => 'Saturday',
      7 => 'Sunday',
      _ => 'Invalid weekday'
    };
