import 'advanced_validators/group_validators.dart';
import 'errors/errors.dart';
import 'errors/warnings.dart';
import 'validators/validators.dart';
import 'validation_context.dart';
import 'validation_resources.dart';
import 'validation_result.dart';

/// Main entry point to build validators.
///
/// Use static methods to get strongly-typed nodes like `Checkit.string` or `Checkit.num`.
abstract class Checkit {
  /// Global config used to build context for each node.
  /// You can override this to set global settings.
  static ValidatorConfig config = ValidatorConfig();

  /// Creates a StringNode validator.
  static StringNode get string => StringNode(config.buildContext());

  /// Creates a NumNode validator.
  static NumNode get num => NumNode(config.buildContext());

  /// Creates a IntNode validator.
  static IntNode get int => IntNode(config.buildContext());

  /// Creates a DoubleNode validator.
  static DoubleNode get double => DoubleNode(config.buildContext());

  /// Creates a DateTimeNode validator.
  static DateTimeNode get dateTime => DateTimeNode(config.buildContext());
}

/// Holds configuration settings for validation behavior.
///
/// This class allows you to configure how validation should behave globally.
/// You can pass an instance of `ValidatorConfig` to control localization,
/// caching, error styles, and rule processing strategy.
///
/// Example:
/// ```dart
/// Checkit.config = ValidatorConfig(
///   stopOnFirstError: true,
///   usePermanentCache: true,
///   caseHandling: CaseHandling.lowercase,
///   errors: CustomCheckitErrors(),
/// );
/// ```
class ValidatorConfig {
  ValidatorConfig({
    this.stopOnFirstError = false,
    this.errors = const CheckitErrors(
      stringErrors: StringCheckitErrors(),
      generalErrors: GeneralCheckitErrors(),
      numErrors: NumCheckitErrors(),
      stringDateErrors: StringDateCheckitErrors(),
      passwordErrors: PasswordCheckitErrors(),
      ipErrors: IpCheckitErrors(),
      intErrors: IntCheckitErrors(),
      doubleErrors: DoubleCheckitErrors(),
    ),
    this.warnings = const Warnings(),
    this.caseHandling = CaseHandling.exact,
    this.usePermanentCache = false,
  });

  /// The error message providers used by validators.
  ///
  /// You can use the default English messages (`CheckitErrors`) or provide
  /// your own implementation to support i18n or customization.
  ///
  /// Default: English error messages.
  final ICheckitErrors errors;

  /// The warning providers used for supplementary messages or notices.
  ///
  /// Default: Empty `Warnings` object.
  final Warnings warnings;

  /// Additional resources that can be used during validation.
  ///
  /// Typically includes formatters, date/time parsing tools, etc.
  final ValidationResourcesBase resources = ValidationResources();

  /// Whether validation should stop at the first error encountered.
  ///
  /// Default: `false` — all validators will be executed.
  final bool stopOnFirstError;

  /// If true, validators will reuse resources between validations.
  ///
  /// Use this to optimize performance for repeated validations.
  ///
  /// Default: `false`.
  final bool usePermanentCache;

  /// Controls case sensitivity behavior during string validation.
  ///
  /// - `CaseHandling.exact` — validation is case-sensitive (e.g. "Hello" ≠ "hello").
  /// - `CaseHandling.ignore` — validation ignores casing (e.g. "Hello" == "hello").
  ///
  /// Default: `CaseHandling.exact`.
  final CaseHandling caseHandling;

  /// Creates a modified copy of this config with optional changes.
  ///
  /// Use this when you want to slightly tweak an existing config.
  ///
  /// Example:
  /// ```dart
  /// final customConfig = defaultConfig.copyWith(
  ///   stopOnFirstError: true,
  ///   caseHandling: CaseHandling.lowercase,
  /// );
  /// ```
  ValidatorConfig copyWith({
    ValidationContext? context,
    bool? stopOnFirstError,
    bool? usePermanentCache,
    ICheckitErrors? errors,
    CaseHandling? caseHandling,
  }) {
    return ValidatorConfig(
      stopOnFirstError: stopOnFirstError ?? this.stopOnFirstError,
      errors: errors ?? this.errors,
      usePermanentCache: usePermanentCache ?? this.usePermanentCache,
      caseHandling: caseHandling ?? this.caseHandling,
    );
  }

  /// Creates a ready-to-use context from this config.
  ValidationContext buildContext() {
    return ValidationContext(
      errors: errors,
      warnings: warnings,
      resources: resources,
      caseHandling: caseHandling,
      usePermanentCache: usePermanentCache,
      stopOnFirstError: stopOnFirstError,
    );
  }
}

/// A compiled set of validators with a context and strategy.
///
/// Typically created from a node using `.build()`
/// or called directly with `.validateOnce(value)`
class ValidatorSet<T> {
  final List<Validator<T>> validators;
  final ValidationContext context;
  final bool stopOnFirstError;

  const ValidatorSet({
    required this.validators,
    required this.context,
    required this.stopOnFirstError,
  });

  ValidationResult validate(T? value, {bool? stopOnFirstError}) {
    context.resources.clear();
    final validator = AndValidator(validators, context);
    return validator.validate(
      value,
      stopOnFirstError: stopOnFirstError ?? this.stopOnFirstError,
    );
  }
}

/// Base class for all validator nodes (string, number, IP, etc).
///
/// Provides chaining, cloning, and conversion to `ValidatorSet`.
abstract class ValidatorNode<T, Self extends ValidatorNode<T, Self>> {
  ValidatorNode(this._context);

  final ValidationContext _context;

  final List<Validator<T>> _validators = [];

  /// Negates another validator.
  Self not(Validator<T> validator, {String? error}) {
    _validators.add(GeneralValidator.not(validator, error: error));

    return this as Self;
  }

  Self any(List<Validator<T>> validators, {String? error}) {
    _validators.add(GeneralValidator.any(validators, error: error));

    return this as Self;
  }

  Self every(List<Validator<T>> validators, {String? error}) {
    _validators.add(GeneralValidator.every(validators, error: error));

    return this as Self;
  }

  /// Adds a custom validator using a function.
  ///
  /// ### Example:
  /// ```dart
  /// final validator = Checkit.string.custom(
  ///  (value, _) => value == value.split('').reversed.join(),
  /// );
  ///
  /// final palindrome = 'level';
  /// final result = validator.validateOnce(palindrome);
  /// ```
  Self custom(
    bool Function(T value, ValidationContext context) validate, {
    String error = '',
  }) {
    _validators.add(GeneralValidator.custom(validate, error: error));
    return this as Self;
  }

  void _addValidators(List<Validator<T>> validators) {
    _validators.addAll(validators);
  }

  /// Quick validation without manually building the set.
  ///
  /// This is a shortcut to call `.build().validate(...)` directly.
  /// Runs validation immediately without storing the validator for reuse.
  /// Useful for one-time checks or quick rules.
  ///
  /// - [value] — The value to validate.
  /// - [stopOnFirstError] — Optional override to stop on the first error.
  ///   If `true`, stops early when a failure is detected. Otherwise,
  ///   all validators are checked. Defaults to the value in the context.
  ///
  /// ### Example:
  /// ```dart
  /// final result = Checkit.string
  ///     .min(3)
  ///     .max(10)
  ///     .validateOnce('hello');
  /// if (result.isValid) print('Valid!');
  /// ```
  ValidationResult validateOnce(T? value, {bool? stopOnFirstError}) =>
      build().validate(value, stopOnFirstError: stopOnFirstError);

  /// Clones this node with an optional different context.
  ///
  /// This allows creating independent validator chains with shared logic
  /// but different behavior depending on the `ValidationContext`.
  ///
  /// ### Example:
  /// ```dart
  /// final baseNode = Checkit.string.min(5);
  /// final clone = baseNode.clone(context: anotherContext);
  /// ```
  Self clone({ValidationContext? context});

  /// Shortcut to clone with updated context.
  ///
  /// Equivalent to `clone(context: ...)`, but more fluent.
  ///
  /// - [context] — The new context to use for the returned clone.
  ///
  /// ### Example:
  /// ```dart
  /// final spanishValidator = baseValidator.withContext(spanishContext);
  /// ```
  Self withContext(ValidationContext context);

  /// Finalizes the validator into a reusable set.
  ///
  /// Creates a `ValidatorSet` from this node. This is optimized for reuse
  /// and allows validation logic to be reused without rebuilding chains.
  ///
  /// - [context] — Optional override to use a different context for the
  ///   resulting `ValidatorSet`.
  ///
  /// Returns a `ValidatorSet<T>` that can be used repeatedly.
  ///
  /// ### Example:
  /// ```dart
  /// final validator = Checkit.num.min(1).max(10).build();
  /// final result = validator.validate(5);
  /// ```
  ValidatorSet<T> build({ValidationContext? context}) {
    final c = context ?? _context;
    return ValidatorSet<T>(
      validators: List.unmodifiable(_validators),
      context: c,
      stopOnFirstError: c.stopOnFirstError,
    );
  }
}

/// Validates strings as formatted dates/times.
///
/// Supports custom formats, ISO-8601, date ranges, and leap year checks.
///
/// ### Example:
/// ```dart
/// Checkit.string
///   .dateTime('yyyy-MM-dd')
///   .notFuture()
///   .minYear(2000);
/// ```
class StringDateNode<T extends String>
    extends ValidatorNode<T, StringDateNode<T>> {
  StringDateNode(super._context);

  @override
  StringDateNode<T> clone({ValidationContext? context}) {
    final clone = StringDateNode<T>(context ?? _context);
    clone._addValidators(List.of(_validators));
    return clone;
  }

  /// Requires a specific date format.
  ///
  /// Checks whether a date conforms to a possible format.
  /// Note that the date '2012-12-12' can correspond to two formats: 'yyyy-MM-dd' and 'yyyy-dd-MM'.
  /// However, the validator does not select a preferred format and only checks the possibility of matching a format.
  /// If the format can be uniquely determined, the validator will return an error:
  /// for example, '2012-31-12' for 'yyyy-MM-dd'. Or succeed: for example, '2012-31-12' for 'yyyy-dd-MM'
  ///
  /// ### Example:
  /// ```dart
  /// final value1 = '2012-12-12';
  /// final value2 = '2012/12/12';
  /// final value3 = '2012-31-12';
  ///
  /// final validator = Checkit.string
  ///   .dateTimeAuto()
  ///   .format('yyyy-MM-dd')
  ///   .build();
  ///
  /// print(validator.validate(value1).isValid); // true
  /// print(validator.validate(value2).isValid); // false
  /// print(validator.validate(value3).isValid); // false
  /// ```
  StringDateNode format(String format, {String? error}) {
    _validators.add(StringDateValidator.format(format, error: error));

    return this;
  }

  /// Specifies the maximum allowed year for the date.
  ///
  /// If the year of the date is greater than the specified `max`, validation fails.
  ///
  /// ### Example:
  /// ```dart
  /// final validator = Checkit.string.dateTime('yyyy-MM-dd').maxYear(2025).build();
  ///
  /// print(validator.validate('2024-12-31').isValid); // true
  /// print(validator.validate('2026-01-01').isValid); // false
  /// ```
  StringDateNode maxYear(int max, {String? error}) {
    _validators.add(StringDateValidator.maxYear(max, error: error));

    return this;
  }

  /// Specifies the minimum allowed year for the date.
  ///
  /// If the year of the date is less than the specified `min`, validation fails.
  ///
  /// ### Example:
  /// ```dart
  /// final validator = Checkit.string.dateTime('yyyy-MM-dd').minYear(2020).build();
  ///
  /// print(validator.validate('2021-01-01').isValid); // true
  /// print(validator.validate('2019-12-31').isValid); // false
  /// ```
  StringDateNode minYear(int min, {String? error}) {
    _validators.add(StringDateValidator.minYear(min, error: error));

    return this;
  }

  /// Requires the date to not be in the past (relative to now).
  ///
  /// If the date is earlier than the current date, validation fails.
  ///
  /// ### Example:
  /// ```dart
  /// final validator = Checkit.string.dateTime('yyyy-MM-dd').notPast().build();
  ///
  /// print(validator.validate('2999-01-01').isValid); // true
  /// print(validator.validate('2000-01-01').isValid); // false
  /// ```
  StringDateNode notPast({String? error}) {
    _validators.add(StringDateValidator.notPast(error: error));

    return this;
  }

  /// Requires the date to not be in the future (relative to now).
  ///
  /// If the date is later than the current date, validation fails.
  ///
  /// ### Example:
  /// ```dart
  /// final validator = Checkit.string.dateTime('yyyy-MM-dd').notFuture().build();
  ///
  /// print(validator.validate('1990-01-01').isValid); // true
  /// print(validator.validate('2999-01-01').isValid); // false
  /// ```
  StringDateNode notFuture({String? error}) {
    _validators.add(StringDateValidator.notFuture(error: error));

    return this;
  }

  /// Requires the date to be before a specific date.
  ///
  /// If the input date is greater than or equal to the `date`, validation fails.
  ///
  /// ### Example:
  /// ```dart
  /// final validator = Checkit.string.dateTime('yyyy-MM-dd').before('2025-01-01').build();
  ///
  /// print(validator.validate('2024-12-31').isValid); // true
  /// print(validator.validate('2025-01-01').isValid); // false
  /// ```
  StringDateNode before(String date, {String? error}) {
    _validators.add(StringDateValidator.before(date, error: error));

    return this;
  }

  /// Requires the date to be after a specific date.
  ///
  /// If the input date is less than or equal to the `date`, validation fails.
  ///
  /// ### Example:
  /// ```dart
  /// final validator = Checkit.string.dateTime('yyyy-MM-dd').after('2020-01-01').build();
  ///
  /// print(validator.validate('2021-01-01').isValid); // true
  /// print(validator.validate('2019-12-31').isValid); // false
  /// ```
  StringDateNode after(String date, {String? error}) {
    _validators.add(StringDateValidator.after(date, error: error));

    return this;
  }

  /// Requires the date to be within the specified range.
  ///
  /// Validates that the input date is within the range defined by [start] and [end].
  ///
  /// - If [inclusive] is `false` (default), the date must be strictly **after** `start` and strictly **before** `end`.
  /// - If [inclusive] is `true`, the date may be equal to `start` or `end`.
  ///
  /// Dates must match the format used earlier in the validator chain (e.g., `dateTime('yyyy-MM-dd')`).
  ///
  /// ### Example (non-inclusive):
  /// ```dart
  /// final validator = Checkit.string
  ///   .dateTime('yyyy-MM-dd')
  ///   .range('2020-01-01', '2022-12-31')
  ///   .build();
  ///
  /// print(validator.validate('2021-06-01').isValid); // true
  /// print(validator.validate('2020-01-01').isValid); // false
  /// print(validator.validate('2022-12-31').isValid); // false
  /// ```
  ///
  /// ### Example (inclusive):
  /// ```dart
  /// final validator = Checkit.string
  ///   .dateTime('yyyy-MM-dd')
  ///   .range('2020-01-01', '2022-12-31', inclusive: true)
  ///   .build();
  ///
  /// print(validator.validate('2020-01-01').isValid); // true
  /// print(validator.validate('2022-12-31').isValid); // true
  /// ```
  StringDateNode range(
    String start,
    String end, {
    String? error,
    bool inclusive = false,
  }) {
    _validators.add(
      StringDateValidator.range(start, end, error: error, inclusive: inclusive),
    );

    return this;
  }

  /// Requires the date to be in a leap year.
  ///
  /// If the year of the date is not a leap year (divisible by 4, but not 100 unless also 400), validation fails.
  ///
  /// ### Example:
  /// ```dart
  /// final validator = Checkit.string.dateTime('yyyy-MM-dd').leapYear().build();
  ///
  /// print(validator.validate('2020-02-29').isValid); // true
  /// print(validator.validate('2021-02-28').isValid); // false
  /// ```
  StringDateNode leapYear({String? error}) {
    _validators.add(StringDateValidator.leapYear(error: error));

    return this;
  }

  /// Requires the date to be in ISO 8601 format.
  ///
  /// This checks whether the input string conforms to the standard ISO format: `yyyy-MM-ddTHH:mm:ssZ`, or a simplified version.
  ///
  /// ### Example:
  /// ```dart
  /// final validator = Checkit.string.dateTimeIso().iso8601().build();
  ///
  /// print(validator.validate('2024-06-20T13:00:00Z').isValid); // true
  /// print(validator.validate('20-06-2024').isValid); // false
  /// ```
  StringDateNode iso8601({String? error}) {
    _validators.add(StringDateValidator.iso8601(error: error));

    return this;
  }

  @override
  StringDateNode<T> withContext(ValidationContext context) {
    return clone(context: context);
  }
}

/// Fluent validator for `num` values (int/double).
///
/// Supports range, positivity, etc.
///
/// ### Example:
/// ```dart
/// Checkit.num.min(1).max(10).validateOnce(5);
/// ```
class NumNode<T extends num> extends ValidatorNode<T, NumNode<T>> {
  NumNode(super._context);

  @override
  NumNode<T> clone({ValidationContext? context}) {
    final clone = NumNode<T>(context ?? _context);
    clone._addValidators(List.of(_validators));
    return clone;
  }

  /// Sets the **minimum allowed value** (default: inclusive).
  ///
  /// Validation fails if the input is less than [min].
  ///
  /// ### Example:
  /// ```dart
  /// final validator = Checkit.num.min(10).build();
  ///
  /// print(validator.validate(5).isValid);   // false
  /// print(validator.validate(10).isValid);  // true
  /// print(validator.validate(15).isValid);  // true
  /// ```
  NumNode<T> min(int min, {String? error, bool inclusive = true}) {
    _validators.add(NumValidator.min(min, error: error, inclusive: inclusive));

    return this;
  }

  /// Sets the **maximum allowed value** (default: inclusive).
  ///
  /// Validation fails if the input is greater than [max].
  ///
  /// ### Example:
  /// ```dart
  /// final validator = Checkit.num.max(100).build();
  ///
  /// print(validator.validate(150).isValid);  // false
  /// print(validator.validate(100).isValid);  // true
  /// print(validator.validate(50).isValid);   // true
  /// ```
  NumNode<T> max(int max, {String? error, bool inclusive = true}) {
    _validators.add(NumValidator.max(max, error: error, inclusive: inclusive));

    return this;
  }

  /// Requires the value to be **positive** (> 0).
  ///
  /// Zero is **not** considered valid.
  ///
  /// ### Example:
  /// ```dart
  /// final validator = Checkit.num.positive().build();
  ///
  /// print(validator.validate(5).isValid);   // true
  /// print(validator.validate(0).isValid);   // false
  /// print(validator.validate(-1).isValid);  // false
  /// ```
  NumNode<T> positive({String? error}) {
    _validators.add(NumValidator.positive(error: error));

    return this;
  }

  /// Requires the value to be **negative** (< 0).
  ///
  /// Zero is **not** considered valid.
  ///
  /// ### Example:
  /// ```dart
  /// final validator = Checkit.num.negative().build();
  ///
  /// print(validator.validate(-10).isValid); // true
  /// print(validator.validate(0).isValid);   // false
  /// print(validator.validate(5).isValid);   // false
  /// ```
  NumNode<T> negative({String? error}) {
    _validators.add(NumValidator.negative(error: error));

    return this;
  }

  /// Validates that the number is within a **specific range**.
  ///
  /// The range is defined by [min] and [max]. You can control whether the boundaries
  /// are inclusive using [includeMin] and [includeMax].
  ///
  /// ### Example (inclusive by default):
  /// ```dart
  /// final validator = Checkit.num.range(1, 10).build();
  ///
  /// print(validator.validate(1).isValid);   // true
  /// print(validator.validate(10).isValid);  // true
  /// print(validator.validate(0).isValid);   // false
  /// print(validator.validate(11).isValid);  // false
  /// ```
  ///
  /// ### Example (exclusive boundaries):
  /// ```dart
  /// final validator = Checkit.num
  ///   .range(1, 10, includeMin: false, includeMax: false)
  ///   .build();
  ///
  /// print(validator.validate(1).isValid);   // false
  /// print(validator.validate(5).isValid);   // true
  /// print(validator.validate(10).isValid);  // false
  /// ```
  NumNode<T> range(
    num min,
    num max, {
    String? error,
    bool includeMin = true,
    bool includeMax = true,
  }) {
    _validators.add(
      NumValidator.range(
        min,
        max,
        error: error,
        includeMin: includeMin,
        includeMax: includeMax,
      ),
    );

    return this;
  }

  @override
  NumNode<T> withContext(ValidationContext context) {
    return clone(context: context);
  }
}

/// A validator node for validating passwords (strings with specific strength rules).
///
/// Supports a fluent chainable API for validating password length, complexity,
/// repetition, and character requirements.
///
/// ### Example:
/// ```dart
/// final validator = Checkit.string
///   .password()
///   .min(8)
///   .hasUppercase()
///   .hasLowercase()
///   .hasDigit()
///   .hasSpecial()
///   .noRepeats()
///   .build();
///
/// final result = validator.validate("Pa$$w0rd!");
/// print(result.isValid); // true
/// ```
class PasswordNode<T extends String> extends ValidatorNode<T, PasswordNode<T>> {
  PasswordNode(super._config);

  @override
  PasswordNode<T> clone({ValidationContext? context}) {
    final clone = PasswordNode<T>(context ?? _context);
    clone._addValidators(List.of(_validators));
    return clone;
  }

  /// Requires the password to have a maximum number of characters.
  ///
  /// ### Example:
  /// ```dart
  /// Checkit.string.password().max(12);
  /// ```
  PasswordNode<T> max(int length, {String? error}) {
    _validators.add(StringValidator.max(length, error: error));

    return this;
  }

  /// Requires the password to have a minimum number of characters.
  ///
  /// ### Example:
  /// ```dart
  /// Checkit.string.password().min(8);
  /// ```
  PasswordNode<T> min(int length, {String? error}) {
    _validators.add(StringValidator.min(length, error: error));

    return this;
  }

  /// Requires at least one uppercase letter (`A-Z`).
  ///
  /// ### Example:
  /// ```dart
  /// Checkit.string.password().hasUppercase();
  /// ```
  PasswordNode<T> hasUppercase({String? error}) {
    _validators.add(PasswordValidator.hasUppercase(error: error));

    return this;
  }

  /// Requires at least one lowercase letter (`a-z`).
  ///
  /// ### Example:
  /// ```dart
  /// Checkit.string.password().hasLowercase();
  /// ```
  PasswordNode<T> hasLowercase({String? error}) {
    _validators.add(PasswordValidator.hasLowercase(error: error));

    return this;
  }

  /// Requires at least one digit (`0-9`).
  ///
  /// ### Example:
  /// ```dart
  /// Checkit.string.password().hasDigit();
  /// ```
  PasswordNode<T> hasDigit({String? error}) {
    _validators.add(PasswordValidator.hasDigit(error: error));

    return this;
  }

  /// Requires at least one letter (either lowercase or uppercase).
  ///
  /// ### Example:
  /// ```dart
  /// Checkit.string.password().hasLetter();
  /// ```
  PasswordNode<T> hasLetter({String? error}) {
    _validators.add(PasswordValidator.hasLetter(error: error));

    return this;
  }

  /// Disallows whitespace characters (` `, `\t`, etc.) in the password.
  ///
  /// ### Example:
  /// ```dart
  /// Checkit.string.password().noSpace();
  /// ```
  PasswordNode<T> noSpace({String? error}) {
    _validators.add(PasswordValidator.noSpace(error: error));

    return this;
  }

  /// Requires at least one special character such as `!@#\$%^&*`.
  ///
  /// You can restrict which characters are allowed using [allowedChars].
  ///
  /// ### Example:
  /// ```dart
  /// Checkit.string.password().hasSpecial(allowedChars: '!@#');
  /// ```
  PasswordNode<T> hasSpecial({String? allowedChars, String? error}) {
    _validators.add(
      PasswordValidator.hasSpecial(allowedChars: allowedChars, error: error),
    );

    return this;
  }

  /// Requires the password to contain at least one character from the given [symbols] string.
  ///
  /// ### Example:
  /// ```dart
  /// Checkit.string.password().hasSymbols('@\$%');
  /// ```
  PasswordNode<T> hasSymbols(String symbols, {String? error}) {
    _validators.add(StringValidator.hasSymbols(symbols, error: error));

    return this;
  }

  /// Validates a **typical secure password** structure.
  ///
  /// Requirements:
  /// - At least 8 characters
  /// - At least one lowercase letter
  /// - At least one uppercase letter
  /// - At least one digit
  /// - At least one special character
  ///
  /// Will fail: `Password1` (no special char), `password!` (no uppercase), `PASS123!` (no lowercase)
  /// Will pass: `P@ssword1`, `Test!234`
  ///
  /// ### Example:
  /// ```dart
  /// final validator = Checkit.string.password().typical().build();
  ///
  /// print(validator.validate('P@ssword1').isValid);   // true
  /// print(validator.validate('password!').isValid);   // false
  /// print(validator.validate('PASSWORD1!').isValid);  // false
  /// print(validator.validate('Passw1!').isValid);     // false (too short)
  /// ```
  PasswordNode<T> typical({String? error}) {
    _validators.add(PasswordValidator.typical());

    return this;
  }

  /// Validates a **strong password** with stricter requirements.
  ///
  /// Requirements:
  /// - At least 10 characters
  /// - At least one lowercase letter
  /// - At least one uppercase letter
  /// - At least one digit
  /// - At least one special character
  /// - No repeated characters in a row
  ///
  /// Will fail: `StrongPass1!` (contains "ss"), `Pass1234!!` (contains "!!"), `Weak12!` (too short)
  /// Will pass: `Str0ng!Pasw`, `My_PasSw0rd!`, `Ab1@cDe#Fg`
  ///
  /// ### Example:
  /// ```dart
  /// final validator = Checkit.string.password().strong().build();
  ///
  /// print(validator.validate('Str0ng!PasS').isValid);     // true
  /// print(validator.validate('StrongPass1!').isValid);    // false (repeating "ss")
  /// print(validator.validate('Weak12!').isValid);         // false (too short)
  /// print(validator.validate('Ab1@cDe#Fg').isValid);      // true
  /// ```
  PasswordNode<T> strong({String? error}) {
    _validators.add(PasswordValidator.strong());

    return this;
  }

  /// Disallows **repeating characters** in a row.
  ///
  /// This validator fails if any character appears twice or more **consecutively**.
  ///
  /// Will fail: `aa`, `11`, `!!`, `pAsswwoooord`
  /// Will pass: `a1b2c3`, `AbC!@#`, `abc123`
  ///
  /// ### Example:
  /// ```dart
  /// final validator = Checkit.string.password().noRepeats().build();
  ///
  /// print(validator.validate('abc123').isValid);       // true
  /// print(validator.validate('AAbbCC').isValid);       // false
  /// print(validator.validate('hello!!').isValid);      // false
  /// ```
  PasswordNode<T> noRepeats({String? error}) {
    _validators.add(PasswordValidator.noRepeats());

    return this;
  }

  /// Validates that the password is **simple**.
  ///
  /// A simple password must:
  /// - Be at least 4 characters long
  /// - Contain only letters and/or digits (no special characters)
  ///
  /// Will fail: `abc`, `123`, `abc$`, `qwe!`
  /// Will pass: `abcd`, `1234`, `abc1`
  ///
  /// ### Example:
  /// ```dart
  /// final validator = Checkit.string.password().simple().build();
  ///
  /// print(validator.validate('1234').isValid);     // true
  /// print(validator.validate('abcd').isValid);     // true
  /// print(validator.validate('abc!').isValid);     // false
  /// print(validator.validate('ab').isValid);       // false
  /// ```
  PasswordNode<T> simple({String? error}) {
    _validators.add(PasswordValidator.simple());

    return this;
  }

  /// Requires the password to have **exactly** [length] characters.
  ///
  /// ### Example:
  /// ```dart
  /// Checkit.string.password().exact(12);
  /// ```
  PasswordNode<T> exact(int length, {String? error}) {
    _validators.add(StringValidator.exact(length, error: error));

    return this;
  }

  @override
  PasswordNode<T> withContext(ValidationContext context) {
    return clone(context: context);
  }
}

/// A fluent builder for validating `String` values.
///
/// Use this class via `Checkit.string` to compose validations in a readable, chained style.
///
/// ### Example:
/// ```dart
/// final result = Checkit.string
///   .min(5)
///   .max(10)
///   .email()
///   .validateOnce('test@example.com');
///
/// if (!result.isValid) {
///   print(result.firstError);
/// }
/// ```
class StringNode<T extends String> extends ValidatorNode<T, StringNode<T>> {
  StringNode(super._config);

  /// Returns a [PasswordNode] with password-specific validation rules.
  ///
  /// ### Example:
  /// ```dart
  /// Checkit.string.password()
  ///   .min(8)
  ///   .hasUppercase()
  ///   .hasDigit();
  /// ```
  PasswordNode password() {
    return PasswordNode(_context);
  }

  /// Returns a [StringDateNode] that validates a specific date format.
  ///
  /// ### Example:
  /// ```dart
  /// Checkit.string.dateTime('yyyy-MM-dd');
  /// ```
  StringDateNode dateTime(String format) {
    final stringDateNode = StringDateNode(_context);
    stringDateNode._addValidators([StringDateValidator.dateTime(format)]);
    return stringDateNode;
  }

  /// Tries to automatically infer the date format from input.
  ///
  /// Optionally prefers a format like `'yyyy-MM-dd'`.
  StringDateNode dateTimeAuto({String? preferredFormat}) {
    final stringDateNode = StringDateNode(_context);
    stringDateNode._addValidators([
      StringDateValidator.dateTimeAuto(preferredFormat: preferredFormat),
    ]);
    return stringDateNode;
  }

  /// Validates an ISO 8601 date-time string.
  ///
  /// ### Example:
  /// ```dart
  /// Checkit.string.dateTimeIso();
  /// ```
  StringDateNode dateTimeIso() {
    final stringDateNode = StringDateNode(_context);
    stringDateNode._addValidators([StringDateValidator.dateTimeIso()]);
    return stringDateNode;
  }

  @override
  StringNode<T> clone({ValidationContext? context}) {
    final clone = StringNode<T>(context ?? _context);
    clone._addValidators(List.of(_validators));
    return clone;
  }

  /// Validates that the string is a valid email address.
  StringNode<T> email({String? error}) {
    _validators.add(StringValidator.email(error: error));

    return this;
  }

  /// Validates that the string is within a **specific range**.
  ///
  /// The range is defined by [min] and [max]. You can control whether the boundaries
  /// are inclusive using [includeMin] and [includeMax].
  ///
  /// ### Example (inclusive by default):
  /// ```dart
  /// final validator = Checkit.string.range(7, 12).build();
  ///
  /// print(validator.validate('Hello World!').isValid);   // true
  /// print(validator.validate('Hello!').isValid);  // false
  /// ```
  ///
  /// ### Example (exclusive boundaries):
  /// ```dart
  /// final validator = Checkit.string
  ///   .range(7, 12, includeMin: false, includeMax: false)
  ///   .build();
  ///
  /// print(validator.validate('Hello World!').isValid);   // false
  /// print(validator.validate('Hello!').isValid);   // false
  /// ```
  StringNode<T> range(
    int min,
    int max, {
    String? error,
    bool includeMin = true,
    bool includeMax = true,
  }) {
    _validators.add(
      StringValidator.range(
        min,
        max,
        error: error,
        includeMin: includeMin,
        includeMax: includeMax,
      ),
    );

    return this;
  }

  /// Validates that the string has at least [length] characters.
  ///
  /// ### Example:
  /// ```dart
  /// Checkit.string.min(4).build().validate('abc'); // isValid: false
  /// ```
  StringNode<T> min(int length, {String? error}) {
    _validators.add(StringValidator.min(length, error: error));

    return this;
  }

  /// Validates that the string has no more than [length] characters.
  ///
  /// ### Example:
  /// ```dart
  /// Checkit.string.max(5).build().validate('abcdef'); // isValid: false
  /// ```
  StringNode<T> max(int length, {String? error}) {
    _validators.add(StringValidator.max(length, error: error));

    return this;
  }

  /// Validates that the string has exactly [length] characters.
  ///
  /// ### Example:
  /// ```dart
  /// Checkit.string.exact(4).build().validate('abcd'); // isValid: true
  /// ```
  StringNode<T> exact(int length, {String? error}) {
    _validators.add(StringValidator.exact(length, error: error));

    return this;
  }

  /// Validates that the string contains the [data] substring.
  ///
  /// ### Example:
  /// ```dart
  /// Checkit.string.contains('test').build().validate('unit test'); // isValid: true
  /// ```
  StringNode<T> contains(String data, {String? error}) {
    _validators.add(StringValidator.contains(data, error: error));

    return this;
  }

  /// Validates that the string contains only letters and digits.
  ///
  /// ### Example:
  /// ```dart
  /// Checkit.string.alphanumeric().build().validate('abc123'); // isValid: true
  /// ```
  StringNode<T> alphanumeric({String? error}) {
    _validators.add(StringValidator.alphanumeric(error: error));

    return this;
  }

  /// Validates that the string contains only alphabetic characters (`a-z`, `A-Z`).
  ///
  /// ### Example:
  /// ```dart
  /// Checkit.string.alpha().build().validate('abc'); // isValid: true
  /// ```
  StringNode<T> alpha({String? error}) {
    _validators.add(StringValidator.alpha(error: error));

    return this;
  }

  /// Validates that the string can be parsed into a double.
  ///
  /// ### Example:
  /// ```dart
  /// Checkit.string.isDouble().build().validate('3.14'); // isValid: true
  /// ```
  StringNode<T> isDouble({String? error}) {
    _validators.add(StringValidator.isDouble(error: error));

    return this;
  }

  /// Validates that the string can be parsed into an integer.
  ///
  /// ### Example:
  /// ```dart
  /// Checkit.string.isInt().build().validate('42'); // isValid: true
  /// ```
  StringNode<T> isInt({String? error}) {
    _validators.add(StringValidator.isInt(error: error));

    return this;
  }

  /// Validates that the string is a valid JWT token format (3 parts separated by `.`).
  ///
  /// ### Example:
  /// ```dart
  /// Checkit.string.jwt().build().validate('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.abc.def'); // isValid: true
  /// ```
  StringNode<T> jwt({String? error}) {
    _validators.add(StringValidator.jwt(error: error));

    return this;
  }

  /// Validates that the string matches the given regex [pattern].
  ///
  /// ### Example:
  /// ```dart
  /// Checkit.string.pattern(r'^[a-z]+$').build().validate('abc'); // isValid: true
  /// ```
  StringNode<T> pattern(String pattern, {String? error}) {
    _validators.add(StringValidator.pattern(pattern, error: error));

    return this;
  }

  /// Validates that the string is exactly equal to [expectedString].
  ///
  /// ### Example:
  /// ```dart
  /// Checkit.string.equals('yes').build().validate('yes'); // isValid: true
  /// ```
  StringNode<T> equals(String expectedString, {String? error}) {
    _validators.add(StringValidator.equals(expectedString, error: error));

    return this;
  }

  /// Validates that the string contains at least one of the provided [symbols].
  StringNode<T> hasSymbols(String symbols, {String? error}) {
    _validators.add(StringValidator.hasSymbols(symbols, error: error));

    return this;
  }

  /// Validates that the string ends with the specified [suffix].
  ///
  /// ### Example:
  /// ```dart
  /// Checkit.string.endsWith('.txt').build().validate('file.txt'); // isValid: true
  /// ```
  StringNode<T> endsWith(String suffix, {String? error}) {
    _validators.add(StringValidator.endsWith(suffix, error: error));

    return this;
  }

  /// Validates that the string starts with the specified [prefix].
  ///
  /// ### Example:
  /// ```dart
  /// Checkit.string.startsWith('https://').build().validate('https://site.com'); // isValid: true
  /// ```
  StringNode<T> startsWith(String suffix, {String? error}) {
    _validators.add(StringValidator.startsWith(suffix, error: error));

    return this;
  }

  /// Validates that the string contains **repeating characters** in a row.
  ///
  /// ### Example:
  /// ```dart
  /// Checkit.string.hasRepeats().build().validate('aa'); // isValid: true
  /// Checkit.string.hasRepeats().build().validate('abc'); // isValid: false
  /// ```
  StringNode<T> hasRepeats({String? error}) {
    _validators.add(StringValidator.hasRepeats(error: error));

    return this;
  }

  /// Switches to IP-specific validation rules.
  ///
  /// ### Example:
  /// ```dart
  /// Checkit.string.ip().v4();
  /// ```
  IpNode ip() {
    final ipNode = IpNode(_context);
    ipNode._addValidators([IpValidator.ip()]);
    return ipNode;
  }

  /// Switches to subnet-specific validation rules using CIDR.
  ///
  /// ### Example:
  /// ```dart
  /// Checkit.string.subnet('192.168.1.0/24').contains('192.168.1.10');
  /// ```
  SubnetNode subnet(String cidr) {
    final subnetNode = SubnetNode(_context);
    subnetNode._addValidators([SubnetValidator.subnet(cidr)]);
    return subnetNode;
  }

  @override
  StringNode<T> withContext(ValidationContext context) {
    return clone(context: context);
  }
}

/// Validates that a string represents a valid IP address.
///
/// Supports v4/v6, local, range, and subnet checks.
///
/// ### Example:
/// ```dart
/// Checkit.string.ip().v4().validateOnce('192.168.1.1');
/// ```
class IpNode<T extends String> extends ValidatorNode<T, IpNode<T>> {
  IpNode(super._config);

  @override
  IpNode<T> clone({ValidationContext? context}) {
    final clone = IpNode<T>(context ?? _context);
    clone._addValidators(List.of(_validators));
    return clone;
  }

  /// Requires the value to be a valid IPv4 address (e.g. 192.168.1.1).
  ///
  /// If the string does not conform to IPv4 format, validation fails.
  ///
  /// ### Example:
  /// ```dart
  /// final validator = Checkit.string.ip().v4().build();
  ///
  /// print(validator.validate('192.168.0.1').isValid); // true
  /// print(validator.validate('::1').isValid); // false
  /// ```
  IpNode<T> v4({String? error}) {
    _validators.add(IpValidator.v4(error: error));

    return this;
  }

  /// Requires the value to be a valid IPv6 address.
  ///
  /// If the string is not a valid IPv6 address, validation fails.
  ///
  /// ### Example:
  /// ```dart
  /// final validator = Checkit.string.ip().v6().build();
  ///
  /// print(validator.validate('::1').isValid); // true
  /// print(validator.validate('192.168.0.1').isValid); // false
  /// ```
  IpNode<T> v6({String? error}) {
    _validators.add(IpValidator.v6(error: error));

    return this;
  }

  /// Requires the IP to be within a specific CIDR subnet (e.g. 192.168.1.0/24).
  ///
  /// If the IP address is outside the given subnet, validation fails.
  ///
  /// ### Example:
  /// ```dart
  /// final validator = Checkit.string.ip().inSubnet('10.0.0.0/8').build();
  ///
  /// print(validator.validate('10.1.2.3').isValid); // true
  /// print(validator.validate('192.168.0.1').isValid); // false
  /// ```
  IpNode<T> inSubnet(String cidr, {String? error}) {
    _validators.add(IpValidator.inSubnet(cidr, error: error));

    return this;
  }

  /// Requires the IP to be link-local (e.g. 169.254.x.x or fe80::/10).
  ///
  /// Link-local addresses are typically used for local network communication.
  /// If the IP is not within the link-local range, validation fails.
  ///
  /// ### Example:
  /// ```dart
  /// final validator = Checkit.string.ip().linkLocal().build();
  ///
  /// print(validator.validate('169.254.10.1').isValid); // true
  /// print(validator.validate('192.168.1.1').isValid); // false
  /// ```
  IpNode<T> linkLocal({String? error}) {
    _validators.add(IpValidator.linkLocal(error: error));

    return this;
  }

  /// Requires the IP to represent localhost (127.0.0.1 for IPv4 or ::1 for IPv6).
  ///
  /// If the IP is not a recognized localhost address, validation fails.
  ///
  /// ### Example:
  /// ```dart
  /// final validator = Checkit.string.ip().localhost().build();
  ///
  /// print(validator.validate('127.0.0.1').isValid); // true
  /// print(validator.validate('::1').isValid);       // true
  /// print(validator.validate('192.168.0.1').isValid); // false
  /// ```
  IpNode<T> localhost({String? error}) {
    _validators.add(IpValidator.localhost(error: error));

    return this;
  }

  /// Requires the IP to be within the loopback range (127.0.0.0/8 or ::1).
  ///
  /// Loopback IPs are typically used for internal testing or self-reference.
  /// If the IP is outside the loopback range, validation fails.
  ///
  /// ### Example:
  /// ```dart
  /// final validator = Checkit.string.ip().loopback().build();
  ///
  /// print(validator.validate('127.5.0.1').isValid); // true
  /// print(validator.validate('::1').isValid);       // true
  /// print(validator.validate('192.168.0.1').isValid); // false
  /// ```
  IpNode<T> loopback({String? error}) {
    _validators.add(IpValidator.loopback(error: error));

    return this;
  }

  /// Requires the IP to be within a specified range from [startIp] to [endIp] (inclusive).
  ///
  /// If the IP is outside the specified range, validation fails.
  ///
  /// ### Example:
  /// ```dart
  /// final validator = Checkit.string.ip().range('192.168.0.1', '192.168.0.255').build();
  ///
  /// print(validator.validate('192.168.0.100').isValid); // true
  /// print(validator.validate('10.0.0.1').isValid);       // false
  /// ```
  IpNode<T> range(String startIp, String endIp, {String? error}) {
    _validators.add(IpValidator.range(startIp, endIp, error: error));

    return this;
  }

  @override
  IpNode<T> withContext(ValidationContext context) {
    return clone(context: context);
  }
}

/// A validator node for checking string values representing IP subnets.
///
/// This node allows validating whether a given subnet (in CIDR format) contains
/// a specific IP address.
///
/// ### Example:
/// ```dart
/// final validator = Checkit.string.subnet('192.168.1.0/24').contains('192.168.1.42').build();
/// final result = validator.validate('192.168.1.0/24');
/// print(result.isValid); // true
///
/// final invalid = validator.validate('10.0.0.0/24');
/// print(invalid.isValid); // false
/// ```
class SubnetNode<T extends String> extends ValidatorNode<T, SubnetNode<T>> {
  SubnetNode(super._locale);

  @override
  SubnetNode<T> clone({ValidationContext? context}) {
    final clone = SubnetNode<T>(context ?? _context);
    clone._addValidators(List.of(_validators));
    return clone;
  }

  /// Validates that the subnet contains the specified [ip] address.
  ///
  /// The input value must be a subnet in CIDR format (e.g., `'192.168.0.0/24'`),
  /// and the [ip] must fall within the subnet's address range.
  ///
  /// ### Example:
  /// ```dart
  /// final validator = Checkit.string.subnet('192.168.0.0/24').contains('192.168.0.42');
  /// print(validator.validateOnce('192.168.0.0/24').isValid); // true
  /// print(validator.validateOnce('10.0.0.0/24').isValid); // false
  /// ```
  SubnetNode<T> contains(String ip, {String? error}) {
    _validators.add(SubnetValidator.contains(ip, error: error));

    return this;
  }

  @override
  SubnetNode<T> withContext(ValidationContext context) {
    return clone(context: context);
  }
}

/// A validator node for `DateTime` values.
///
/// This node allows you to validate `DateTime` objects against various
/// constraints such as range, minimum/maximum year, whether the date is in
/// the past or future, and more.
///
/// ### Example:
/// ```dart
/// final validator = Checkit.dateTime()
///   .notFuture()
///   .minYear(2000)
///   .build();
///
/// final result = validator.validate(DateTime(1999));
/// print(result.isValid); // false
/// ```
class DateTimeNode<T extends DateTime>
    extends ValidatorNode<T, DateTimeNode<T>> {
  DateTimeNode(super._context);

  @override
  DateTimeNode<T> clone({ValidationContext? context}) {
    final clone = DateTimeNode<T>(context ?? _context);
    clone._addValidators(List.of(_validators));
    return clone;
  }

  /// Requires the year of the `DateTime` to be less than or equal to [max].
  ///
  /// ### Example:
  /// ```dart
  /// final validator = Checkit.dateTime().maxYear(2025).build();
  /// print(validator.validate(DateTime(2026)).isValid); // false
  /// ```
  DateTimeNode maxYear(int max, {String? error}) {
    _validators.add(DateTimeValidator.maxYear(max, error: error));

    return this;
  }

  /// Requires the year of the `DateTime` to be greater than or equal to [min].
  ///
  /// ### Example:
  /// ```dart
  /// final validator = Checkit.dateTime().minYear(2000).build();
  /// print(validator.validate(DateTime(1999)).isValid); // false
  /// ```
  DateTimeNode minYear(int min, {String? error}) {
    _validators.add(DateTimeValidator.minYear(min, error: error));

    return this;
  }

  /// Fails if the date is in the past (i.e., before `DateTime.now()`).
  ///
  /// ### Example:
  /// ```dart
  /// final validator = Checkit.dateTime().notPast().build();
  /// print(validator.validate(DateTime.now().subtract(Duration(days: 1))).isValid); // false
  /// ```
  DateTimeNode notPast({String? error}) {
    _validators.add(DateTimeValidator.notPast(error: error));

    return this;
  }

  /// Fails if the date is in the future (i.e., after `DateTime.now()`).
  ///
  /// ### Example:
  /// ```dart
  /// final validator = Checkit.dateTime().notFuture().build();
  /// print(validator.validate(DateTime.now().add(Duration(days: 1))).isValid); // false
  /// ```
  DateTimeNode notFuture({String? error}) {
    _validators.add(DateTimeValidator.notFuture(error: error));

    return this;
  }

  /// Fails if the date is not before the given [date].
  ///
  /// ### Example:
  /// ```dart
  /// final validator = Checkit.dateTime().before(DateTime(2025)).build();
  /// print(validator.validate(DateTime(2030)).isValid); // false
  /// ```
  DateTimeNode before(DateTime date, {String? error}) {
    _validators.add(DateTimeValidator.before(date, error: error));

    return this;
  }

  /// Fails if the date is not after the given [date].
  ///
  /// ### Example:
  /// ```dart
  /// final validator = Checkit.dateTime().after(DateTime(2020)).build();
  /// print(validator.validate(DateTime(2010)).isValid); // false
  /// ```
  DateTimeNode after(DateTime date, {String? error}) {
    _validators.add(DateTimeValidator.after(date, error: error));

    return this;
  }

  /// Validates that the date is within the given range.
  ///
  /// By default, the range is inclusive (i.e., boundaries are allowed).
  /// Set [inclusive] to `false` if the range should be strict.
  ///
  /// ### Example:
  /// ```dart
  /// final validator = Checkit.dateTime()
  ///   .range(DateTime(2020), DateTime(2025))
  ///   .build();
  ///
  /// print(validator.validate(DateTime(2023)).isValid); // true
  /// print(validator.validate(DateTime(2026)).isValid); // false
  /// ```
  DateTimeNode range(
    DateTime start,
    DateTime end, {
    String? error,
    bool inclusive = true,
  }) {
    _validators.add(
      DateTimeValidator.range(start, end, error: error, inclusive: inclusive),
    );

    return this;
  }

  /// Requires the date to be in a leap year.
  ///
  /// ### Example:
  /// ```dart
  /// final validator = Checkit.dateTime().leapYear().build();
  /// print(validator.validate(DateTime(2024, 2, 29)).isValid); // true
  /// print(validator.validate(DateTime(2023, 2, 28)).isValid); // false
  /// ```
  DateTimeNode leapYear({String? error}) {
    _validators.add(DateTimeValidator.leapYear(error: error));

    return this;
  }

  @override
  DateTimeNode<T> withContext(ValidationContext context) {
    return clone(context: context);
  }
}

/// A validator node for integers.
///
/// Provides a set of rules specifically for validating `int` values.
///
/// ### Example:
/// ```dart
/// final validator = Checkit.int()
///   .min(10)
///   .max(100)
///   .even()
///   .build();
///
/// final result = validator.validate(42);
/// print(result.isValid); // true
/// ```
class IntNode<T extends int> extends ValidatorNode<T, IntNode<T>> {
  IntNode(super._context);

  @override
  IntNode<T> clone({ValidationContext? context}) {
    final clone = IntNode<T>(context ?? _context);
    clone._addValidators(List.of(_validators));
    return clone;
  }

  /// Requires the number to be greater than or equal to [min].
  ///
  /// ### Example:
  /// ```dart
  /// final validator = Checkit.int().min(5).build();
  /// print(validator.validate(4).isValid); // false
  /// ```
  IntNode<T> min(int min, {String? error}) {
    _validators.add(NumValidator.min(min, error: error));

    return this;
  }

  /// Requires the number to be less than or equal to [max].
  ///
  /// ### Example:
  /// ```dart
  /// final validator = Checkit.int().max(10).build();
  /// print(validator.validate(11).isValid); // false
  /// ```
  IntNode<T> max(int max, {String? error}) {
    _validators.add(NumValidator.max(max, error: error));

    return this;
  }

  /// Requires the number to be strictly positive (> 0).
  ///
  /// ### Example:
  /// ```dart
  /// final validator = Checkit.integer().positive().build();
  /// print(validator.validate(0).isValid); // false
  /// ```
  IntNode<T> positive({String? error}) {
    _validators.add(NumValidator.positive(error: error));

    return this;
  }

  /// Requires the number to be strictly negative (< 0).
  ///
  /// ### Example:
  /// ```dart
  /// final validator = Checkit.int().negative().build();
  /// print(validator.validate(1).isValid); // false
  /// ```
  IntNode<T> negative({String? error}) {
    _validators.add(NumValidator.negative(error: error));

    return this;
  }

  /// Requires the number to be within the range `[min, max]` (default: inclusive).
  ///
  /// ### Example:
  /// ```dart
  /// final validator = Checkit.int().range(5, 10).build();
  /// print(validator.validate(7).isValid); // true
  /// print(validator.validate(11).isValid); // false
  /// ```
  IntNode<T> range(
    int min,
    int max, {
    String? error,
    bool includeMin = true,
    bool includeMax = true,
  }) {
    _validators.add(
      NumValidator.range(
        min,
        max,
        error: error,
        includeMax: includeMax,
        includeMin: includeMin,
      ),
    );

    return this;
  }

  /// Requires the number to have exactly [count] digits.
  ///
  /// ### Example:
  /// ```dart
  /// final validator = Checkit.int().digitCount(3).build();
  /// print(validator.validate(123).isValid); // true
  /// print(validator.validate(12).isValid); // false
  /// ```
  IntNode<T> digitCount(int count, {String? error}) {
    _validators.add(IntValidator.digitCount(count, error: error));

    return this;
  }

  /// Requires the number to be divisible by [divisor] with no remainder.
  ///
  /// ### Example:
  /// ```dart
  /// final validator = Checkit.int().divisibleBy(3).build();
  /// print(validator.validate(9).isValid); // true
  /// print(validator.validate(10).isValid); // false
  /// ```
  IntNode<T> divisibleBy(int divisor, {String? error}) {
    _validators.add(IntValidator.divisibleBy(divisor, error: error));

    return this;
  }

  /// Requires the number to be even.
  ///
  /// ### Example:
  /// ```dart
  /// final validator = Checkit.int().even().build();
  /// print(validator.validate(4).isValid); // true
  /// print(validator.validate(3).isValid); // false
  /// ```
  IntNode<T> even({String? error}) {
    _validators.add(IntValidator.even(error: error));

    return this;
  }

  /// Requires the number to be odd.
  ///
  /// ### Example:
  /// ```dart
  /// final validator = Checkit.int().odd().build();
  /// print(validator.validate(5).isValid); // true
  /// print(validator.validate(6).isValid); // false
  /// ```
  IntNode<T> odd({String? error}) {
    _validators.add(IntValidator.odd(error: error));

    return this;
  }

  /// Requires the number to match one of the values from [allowedValues].
  ///
  /// ### Example:
  /// ```dart
  /// final validator = Checkit.int().oneOf({1, 2, 3}).build();
  /// print(validator.validate(2).isValid); // true
  /// print(validator.validate(4).isValid); // false
  /// ```
  IntNode<T> oneOf(Set<int> allowedValues, {String? error}) {
    _validators.add(IntValidator.oneOf(allowedValues, error: error));

    return this;
  }

  /// Requires the number to be a prime number.
  ///
  /// ### Example:
  /// ```dart
  /// final validator = Checkit.int().prime().build();
  /// print(validator.validate(7).isValid); // true
  /// print(validator.validate(8).isValid); // false
  /// ```
  IntNode<T> prime({String? error}) {
    _validators.add(IntValidator.prime(error: error));

    return this;
  }

  /// Requires the number to be in the range `[min, max]` and match the [step].
  ///
  /// You can control inclusivity using [includeMin] and [includeMax].
  ///
  /// ### Example:
  /// ```dart
  /// final validator = Checkit.int()
  ///   .rangeWithStep(10, 20, 5)
  ///   .build();
  ///
  /// print(validator.validate(15).isValid); // true
  /// print(validator.validate(17).isValid); // false
  /// ```
  IntNode<T> rangeWithStep(
    int min,
    int max,
    int step, {
    String? error,
    bool includeMin = true,
    bool includeMax = true,
  }) {
    _validators.add(
      IntValidator.rangeWithStep(
        min,
        max,
        step,
        error: error,
        includeMin: includeMin,
        includeMax: includeMax,
      ),
    );

    return this;
  }

  @override
  IntNode<T> withContext(ValidationContext context) {
    return clone(context: context);
  }
}

/// A validator node for `double` values.
///
/// Provides a set of rules to validate floating-point numbers.
///
/// ### Example:
/// ```dart
/// final validator = Checkit.double()
///   .positive()
///   .finite()
///   .build();
///
/// print(validator.validate(12.5).isValid); // true
/// print(validator.validate(double.infinity).isValid); // false
/// ```
class DoubleNode<T extends double> extends ValidatorNode<T, DoubleNode<T>> {
  DoubleNode(super._context);

  @override
  DoubleNode<T> clone({ValidationContext? context}) {
    final clone = DoubleNode<T>(context ?? _context);
    clone._addValidators(List.of(_validators));
    return clone;
  }

  /// Requires the number to be greater than or equal to [min].
  ///
  /// ### Example:
  /// ```dart
  /// final validator = Checkit.double().min(1).build();
  /// print(validator.validate(0.5).isValid); // false
  /// ```
  DoubleNode<T> min(int min, {String? error}) {
    _validators.add(NumValidator.min(min, error: error));

    return this;
  }

  /// Requires the number to be less than or equal to [max].
  ///
  /// ### Example:
  /// ```dart
  /// final validator = Checkit.double().max(100).build();
  /// print(validator.validate(101.0).isValid); // false
  /// ```
  DoubleNode<T> max(int max, {String? error}) {
    _validators.add(NumValidator.max(max, error: error));

    return this;
  }

  /// Requires the number to be strictly greater than 0.
  ///
  /// ### Example:
  /// ```dart
  /// final validator = Checkit.double().positive().build();
  /// print(validator.validate(-1.0).isValid); // false
  /// ```
  DoubleNode<T> positive({String? error}) {
    _validators.add(NumValidator.positive(error: error));

    return this;
  }

  /// Requires the number to be strictly less than 0.
  ///
  /// ### Example:
  /// ```dart
  /// final validator = Checkit.double().negative().build();
  /// print(validator.validate(0.1).isValid); // false
  /// ```
  DoubleNode<T> negative({String? error}) {
    _validators.add(NumValidator.negative(error: error));

    return this;
  }

  /// Requires the number to be within the range `[min, max]`.
  ///
  /// ### Example:
  /// ```dart
  /// final validator = Checkit.double().range(0, 10).build();
  /// print(validator.validate(5.0).isValid); // true
  /// print(validator.validate(15.0).isValid); // false
  /// ```
  DoubleNode<T> range(
    int min,
    int max, {
    String? error,
    bool includeMin = true,
    bool includeMax = true,
  }) {
    _validators.add(
      NumValidator.range(
        min,
        max,
        error: error,
        includeMax: includeMax,
        includeMin: includeMin,
      ),
    );

    return this;
  }

  /// Requires the number to have a fractional part (i.e., not an integer).
  ///
  /// ### Example:
  /// ```dart
  /// final validator = Checkit.double().decimal().build();
  /// print(validator.validate(5.5).isValid); // true
  /// print(validator.validate(6.0).isValid); // false
  /// ```
  DoubleNode<T> decimal({String? error}) {
    _validators.add(DoubleValidator.decimal(error: error));

    return this;
  }

  /// Requires the number to be finite (not `NaN`, `Infinity`, or `-Infinity`).
  ///
  /// ### Example:
  /// ```dart
  /// final validator = Checkit.double().finite().build();
  /// print(validator.validate(double.infinity).isValid); // false
  /// ```
  DoubleNode<T> finite({String? error}) {
    _validators.add(DoubleValidator.finite(error: error));

    return this;
  }

  /// Requires the number to be an integer (i.e., no fractional part).
  ///
  /// ### Example:
  /// ```dart
  /// final validator = Checkit.double().integer().build();
  /// print(validator.validate(5.0).isValid); // true
  /// print(validator.validate(5.1).isValid); // false
  /// ```
  DoubleNode<T> integer({String? error}) {
    _validators.add(DoubleValidator.integer(error: error));

    return this;
  }

  @override
  DoubleNode<T> withContext(ValidationContext context) {
    return clone(context: context);
  }
}
