# date_and_time

This package provides `Date` and `Time` types they are clean immutable types without the complexity of `DateTime`.

## Why Separate Date and Time?

Dates and times usually serve distinct purposes and we often use them independently. So, it doesn't make sense to smash them together by default. Changing the time of a `DateTime` means making a copy of both and replacing the time, while changing the date of the `DateTime` also means copying both and replace the date. This is very onerous and makes code more confusing. 

The other sweetener is that if you use `Date.today()`  or `Time.now()`, you can easily mock the time in your tests. Mocking time in Flutter apps that depend heavily on time is very onerous because using once instance of `DateTime.now()` will make your tests flaky and hard to diagnose.

### Dates
Represent calendar days (birthdays, holidays, deadlines) where the time is irrelevant.

### Times 
Represent a point in time for any date. 

Using `DateTime` for these cases:
- Adds unnecessary complexity
- Makes comparison logic more complicated
- Makes it harder to serialize/deserialize when you only need one component
- Makes it harder change one value without changing the other

This package provides two extension types that solve these problems:
- `Date` - For working with calendar dates
- `Time` - For working with times of day

## Features

- ✨ Pure immutable types
- 🎯 Intuitive API design
- 🔄 Easy conversion to and from strings
- 🧮 Date arithmetic and time comparison
- 🌐 UTC-first approach with local time conversion support
- 🔄 Utility functions for common date/time operations

## Timezone

This library uses UTC by default. This is because using UTC is generally safer and local timezone should generally only be used for display purposes. All operations are performed in UTC, with convenient methods to convert to local time when needed for display.

## Getting Started

Install the package according the "Installing" tab here on Pub Dev.

## Usage

### Working with Dates

```dart
// Get today's date (in UTC)
final today = Date.today();

final utcBirthday = Date.tryParse('1990-04-15T00:00:00Z'); // Recommended approach. Explicitly UTC

// Parse from string (assumes local time if no timezone is provided)
final birthday = Date.tryParse('1990-04-15'); // The time will be parsed as local time and converted to UTC, which probably won't be what you want.

// Create from values (in UTC)
final date = Date.fromValues(year: 2024, month: 3, day: 15);

// Access components
print(date.year);    // 2024
print(date.month);   // 3
print(date.day);     // 15
print(date.weekday); // 5 (Friday)

// Get underlying DateTime (UTC)
final dateTime = date.asDateTime;

// Convert to local DateTime
final localDateTime = date.toLocalDateTime();

// Date arithmetic
final tomorrow = date.add(Duration(days: 1));
final yesterday = date.subtract(Duration(days: 1));

// ISO 8601 formatting
print(date.toIso8601String()); // 2024-03-15T00:00:00.000Z
```

### Working with Times

```dart
// Get current time (in UTC)
final now = Time.now();

// Create from values (in UTC)
final time = Time.fromValues(hour: 14, minute: 30, second: 15);

// Access components
print(time.hour);         // 14
print(time.minute);       // 30
print(time.second);       // 15
print(time.totalSeconds); // 52215

// Parse from string (assumes local time if no timezone is provided)
final parsed = Time.tryParse('14:30:15'); // Parsed as local time
final utcParsed = Time.tryParse('14:30:15Z'); // Explicitly UTC

// Compare times
final meetingTime = Time.fromValues(hour: 14, minute: 30);
final isLater = meetingTime.compareTo(now) > 0;

// ISO 8601 formatting
print(time.toIso8601String()); // 14:30:15
```

### Utility Functions

```dart
// Combine Date and Time into DateTime
final date = Date.today();
final time = Time.now();
final dateTime = combineDateAndTime(date, time); // Returns UTC DateTime

// Get current UTC time
final currentUtc = now; // Returns current UTC DateTime
print(nowAsIso8601); // "2024-03-20T14:30:00.000Z"

// Get current local time
final currentLocal = nowLocal; // Returns current local DateTime
print(nowLocalAsIso8601); // "2024-03-20T14:30:00.000+10:00"
```

## Testing Support

The package includes Zone-based time control for testing. This allows you to provide custom implementations of the current date and time. All mocked times are handled in UTC:

```dart
void main() {
  test('custom time test', () {
    final customTime = DateTime.utc(2024, 1, 1, 12, 0);
    
    runZoned(
      () {
        final now = Time.now(); // Will be in UTC
        expect(now.hour, equals(12));
        expect(now.minute, equals(0));

        final today = Date.today(); // Will be in UTC
        expect(today.year, equals(2024));
        expect(today.month, equals(1));
        expect(today.day, equals(1));
      },
      zoneValues: {nowKey: () => customTime},
    );
  });
}
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## License

This project is licensed under the BSD-3 License - see the [LICENSE](LICENSE) file for details.