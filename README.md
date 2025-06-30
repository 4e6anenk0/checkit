
## 🛡️ Checkit

**Checkit** is a modular, extensible validation library for Dart. It supports validation chains, localization, custom rules, and flexible configuration. Perfect for both client and server use cases.

### ✨ Features

* Simple and readable builder-style API
* Custom validators
* Localization support
* String, number, date, IP, password, subnet validators
* Global and per-instance configuration
* Easy to extend and integrate

## 🚀 Quick Start

### Installation

```yaml
dependencies:
  checkit: ^1.0.0
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

## 🔧 Built-in Validators

### Strings

```dart
Checkit.string
  .min(3)
  .max(20)
  .startsWith("abc")
  .validateOnce("abc123");
```

### Numbers

```dart
Checkit.num
  .positive()
  .range(10, 100)
  .validateOnce(42);
```

### Passwords

```dart
Checkit.string
  .password()
  .min(8)
  .hasUppercase()
  .hasDigit()
  .noSpace()
  .validateOnce("S3cureP@ss");
```

### Dates (from strings)

```dart
Checkit.string
  .dateTime("yyyy-MM-dd")
  .notFuture()
  .validateOnce("2023-12-01");
```

### IP & Subnets

```dart
Checkit.string.ip().v4().validateOnce("192.168.0.1");

Checkit.string.subnet("192.168.0.0/24").contains("192.168.0.42");
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
* ⏳ Locale auto-generation
* ⏳ Async validation support

## ❤️ Author

Crafted with care and a focus on performance.
Contributions, issues, and stars are always welcome!
