
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

Вот пример раздела для `README.md`, который красиво раскрывает идею **инверсии валидаторов**:

---

## 🔁 Inverting Validators with `.not()`

Checkit supports expressive validation chains — including the ability to **invert any validator** using the `.not(...)` method. This allows you to declare what a value **must not** contain in a readable, declarative way.

### Use Case: Excluding Specific Characters in a Password

For example, imagine you want to validate that a password **must contain** certain characters (e.g., "B", "C", "D"), but **must not contain** "A" or "F". With Checkit, this becomes simple and expressive:

```dart
void main() {
  final validator = Checkit.string
      .password()
      .not(StringValidator.hasSymbols('A'), error: 'Value must not be A')
      .hasSymbols('B')
      .hasSymbols('C')
      .hasSymbols('D')
      .not(StringValidator.hasSymbols('F'), error: 'Value must not be F');

  final password = 'ABCDEF';
  final result = validator.validateOnce(password);

  result.prettyPrint();
}
```

### 💡 Output

```
❌ Invalid
  1. Value must not be A
  2. Value must not be F
```

### 🧠 Behind the Scenes

Any standard validator can be inverted via:

```dart
.not(validator, error: 'Custom error message')
```

This feature enables:

* **Negation logic** in clean chains (no need for custom predicates).
* **Complex logical flows** (e.g., "must be one of... but not...").
* **Safe composition** of reusable validator modules.

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
