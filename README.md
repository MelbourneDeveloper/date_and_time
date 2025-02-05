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
- 🌍 Time zone independent (note that you still need to be aware of the timezone you are working with)

## Getting Started

Install the package according the "Installing" tab here on Pub Dev.

## Usage

### Working with Dates

```dart
// Get today's date
final today = Date.today();

// Parse from string
final birthday = Date.tryParse('1990-04-15');

// Create from values
final date = Date.fromValues(year: 2024, month: 3, day: 15);

// Access components
print(date.year);    // 2024
print(date.month);   // 3
print(date.day);     // 15
print(date.weekday); // 5 (Friday)

// Date arithmetic
final tomorrow = date.add(Duration(days: 1));
final yesterday = date.subtract(Duration(days: 1));

// ISO 8601 formatting
print(date.toIso8601String()); // 2024-03-15
```

### Working with Times

```dart
// Get current time
final now = Time.now();

// Create from values
final time = Time.fromValues(hour: 14, minute: 30, second: 15);

// Access components
print(time.hour);         // 14
print(time.minute);       // 30
print(time.second);       // 15
print(time.totalSeconds); // 52215

// Parse from string
final parsed = Time.tryParse('14:30:15');

// Compare times
final meetingTime = Time.fromValues(hour: 14, minute: 30);
final isLater = meetingTime.compareTo(now) > 0;

// ISO 8601 formatting
print(time.toIso8601String()); // 14:30:15
```

## Testing Support

The package includes Zone-based time control for testing. This allows you to provide custom implementations of the current date and time:

```dart
void main() {
  test('custom time test', () {
    final customTime = DateTime(2024, 1, 1, 12, 0);
    
    runZoned(
      () {
        final now = Time.now();
        expect(now.hour, equals(12));
        expect(now.minute, equals(0));
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
