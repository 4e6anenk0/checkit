
# 🛡️ Checkit

**Checkit** is a modular, extensible validation library for Dart. It supports validation chains, localization, custom rules, and flexible configuration. Perfect for both client and server use cases.

## ✨ Features

* Simple and readable builder-style API
* Custom validators
* Localization support with easy customization
* String, num, int, double, string-date, datetime, IP, password and subnet validators
* Easy to extend and integrate
* Zero dependencies (pure Dart)

## 🚀 Quick Start

### Installation

Add the following dependency to your project:

```yaml
dependencies:
  checkit: ^1.0.0
```

Or run via CLI for Dart:

```sh
dart pub add checkit
```

Or for Flutter:

```sh
flutter pub add checkit
```

### Basic Usage

```dart
import 'package:checkit/checkit.dart';

final result = Checkit.string
  .min(5)
  .max(10)
  .email()
  .validateOnce("example@mail.com");

if (result.isValid) {
  print("Success!");
} else {
  print("Error: ${result.errors}");
}
```

Or even simpler with prettyPrint() method:

```dart
import 'package:checkit/checkit.dart';

final result = Checkit.string
  .min(5)
  .max(10)
  .email()
  .validateOnce("example@mail.com");

result.prettyPrint();
```

## 🔧 Built-in Validators

### String Validator

```dart
Checkit.string
  .min(3)
  .max(20)
  .startsWith("abc")
  .validateOnce("abc123");
```

Available String Validations:

* min, max, exact, range
* email
* alpha, alphanumeric
* contains, hasSymbols
* isDouble, isInt,
* jwt, pattern
* equals, endsWith, startsWith

Special methods:

* custom, not, clone, withContext, build

And refs to other nodes:

* dateTime, dateTimeAuto, dateTimeIso
* password
* ip, subnet

### Number Validator

```dart
Checkit.num
  .positive()
  .range(10, 100)
  .validateOnce(42);
```

Available Num Validations:

* min, max, range
* positive, negative
* multiple

Special methods:

* custom, not, clone, withContext, build

### Integer Validator

```dart
Checkit.int
  .positive()
  .range(10, 100)
  .validateOnce(42);
```

Available Num Validations:

* min, max, range, rangeWithStep
* positive, negative
* multiple
* digitCount
* divisibleBy
* even, odd, prime
* oneOf

Special methods:

* custom, not, clone, withContext, build

### Double Validator

```dart
Checkit.double
  .positive()
  .range(10, 100)
  .validateOnce(42);
```

Available Double Validations:

* min, max, range
* positive, negative
* decimal, finite, integer

Special methods:

* custom, not, clone, withContext, build

### Password Validator

```dart
Checkit.string
  .password()
  .min(8)
  .hasUppercase()
  .hasDigit()
  .noSpace()
  .validateOnce("S3cureP@ss");
```

Available Password Validations:

* common
* min, max, exact, range
* hasUppercase, hasLowercase, hasDigit, hasLetter, noSpace, hasSpecial, hasSymbols

Special methods:

* custom, not, clone, withContext, build

### Date Validator (from String)

#### If the format is known

```dart
Checkit.string
  .dateTime("yyyy-MM-dd")
  .notFuture()
  .validateOnce("2023-12-01");
```

#### If the format is unknown

Be careful, as it can determine the month and day values ​​itself through the method for cases when the date does not give an unambiguous correspondence.

```dart

Checkit.string
  .dateTimeAuto()
  .notFuture()
  .validateOnce("2023/12/01");
```

Available Date (String) Validations:

* format
* maxYear, minYear
* notPast, notFuture
* before, after, range
* leapYear
* iso8601

Special methods:

* custom, not, clone, withContext, build

### DateTime Validator

```dart
Checkit.dateTime.notFuture().validateOnce(DateTime(2023, 12, 1));

```

Available DateTime Validations:

* maxYear, minYear
* notPast, notFuture
* before, after, range
* leapYear

Special methods:

* custom, not, clone, withContext, build

### IP & Subnets

```dart
Checkit.string.ip().v4().validateOnce("192.168.0.1");
```

Available IP Validations:

* v4, v6
* inSubnet
* linkLocal, localhost, loopback
* range

Special methods:

* custom, not, clone, withContext, build

```dart
Checkit.string.subnet("192.168.0.0/24").contains("192.168.0.42");
```

Available Subnet Validations:

* contains

Special methods:

* custom, not, clone, withContext, build

## 🔁 Inverting Validators with `.not()`

Checkit supports expressive validation chains — including the ability to **invert any validator** using the `.not(...)` method. This allows you to declare what a value **must not** contain in a readable, declarative way.

### Use Case: Excluding Specific Characters in a Password

For example, imagine you want to validate that a password **must contain** certain characters (e.g., "B", "C", "D"), but **must not contain** "A" or "F". With Checkit, this becomes simple and expressive:

```dart
void main() {
  final validator = Checkit.string
      .password()
      .not(StringValidator.hasSymbols('A'), error: 'Value must not be A')
      .hasSymbols('BCD')
      .not(StringValidator.hasSymbols('F'), error: 'Value must not be F');

  final password = 'ABCDEF';
  final result = validator.validateOnce(password);

  result.prettyPrint();
}
```

### Output

```sh
❌ Invalid
  1. Value must not be A
  2. Value must not be F
```

Any standard validator can be inverted via:

```dart
.not(validator, error: 'Custom error message')
```

## ⚙️ Configuration

You can globally configure Checkit:

```dart
Checkit.config = ValidatorConfig(
  stopOnFirstError: true,
  usePermanentCache: true,
);
```

Or use your own `ValidationContext`:

```dart
final context = Checkit.config.copyWith(stopOnFirstError: false).buildContext();
Checkit.string.withContext(context).min(5).validateOnce("test");
```

## 🌍 Localization

Checkit uses English error messages by default. You can provide your own:

```dart
Checkit.config = ValidatorConfig(
  errors: MyCustomErrors(), // Implements ICheckitErrors
);
```

You can also integrate `intl` using an optional `checkit_intl` package (planned).

## 🧩 Custom Validators

Create your own validator:

```dart
class CustomValidator {
  static Validator<String> onlyLowercase({String? error}) {
    return (value, context) {
      if (value != null && value == value.toLowerCase()) return null;
      return error ?? context.errors.generalErrors.invalidValue;
    };
  }
}

// Usage:
Checkit.string.custom(CustomValidator.onlyLowercase(), error: "Lowercase only");
```

## 🧪 Testing

```dart
final result = Checkit.string.min(5).validateOnce("hi");

expect(result.isValid, false);
expect(result.errors.first.message, contains("Minimum 5 characters"));
```

## 📁 Library Structure

* `Checkit` — Main entry point
* `ValidatorConfig` — Global configuration
* `ValidationContext` — Execution context
* `ICheckitErrors` — Localization interface
* `ValidatorSet` — Set of validators
* `ValidatorNode<T>` — Builder-style chain

## 📌 TODO / Roadmap

* ✅ Custom rules support
* ✅ Localization support
* ⏳ `intl` integration
* ⏳ Flutter adapter (AppLocalizations integration)

## ❤️ Author

Crafted with care and a focus on performance.
Contributions, issues, and stars are always welcome!
