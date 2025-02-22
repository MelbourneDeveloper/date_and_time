## 0.0.5-alpha

- Fix documentation inaccuracy around date parsing and UTC handling.
  
## 0.0.4-alpha

- Breaking change: switches to using DateTime's underlying toIso8601String instead of manually formatting the string.

## 0.0.3-alpha

- Switched to UTC-first approach for all date and time operations
- Added new utility functions:
  - `combineDateAndTime` for combining Date and Time into DateTime
  - `now`, `nowAsIso8601` for UTC time access
  - `nowLocal`, `nowLocalAsIso8601` for local time access
- Enhanced `Date` and `Time` types:
  - Added UTC conversion handling
  - Improved parsing with timezone support
  - Added `asDateTime` and `toLocalDateTime` methods
- Improved testing support with UTC-based time mocking
- Fixed timezone-related edge cases and improved documentation

## 0.0.2-alpha

- Fix some bugs around time parsing and validating those values


## 0.0.1-alpha

- Initial version. The API may change.
