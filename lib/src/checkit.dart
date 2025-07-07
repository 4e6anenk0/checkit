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

  static IntNode get int => IntNode(config.buildContext());

  static DoubleNode get double => DoubleNode(config.buildContext());

  static DateTimeNode get dateTime => DateTimeNode(config.buildContext());
}

/// Global configuration for validation behavior.
///
/// Controls how validators behave, what errors to show,
/// whether to stop on first error, and caching strategy.
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
  final ICheckitErrors errors;
  final Warnings warnings;
  final ValidationResourcesBase resources = ValidationResources();
  final bool stopOnFirstError;
  final bool usePermanentCache;
  final CaseHandling caseHandling;

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

  /* Self any(List<Validator<T>> validators, {ValidationContext? context}) {
    final relContext =
        context != null
            ? context.copyWith(stopOnFirstError: false)
            : _context.copyWith(stopOnFirstError: false);
    _validators.add(
      GeneralValidator.wrapAdvanced(OrValidator<T>(validators, relContext)),
    );

    return this as Self;
  }

  Self every(List<Validator<T>> validators, {ValidationContext? context}) {
    final relContext =
        context != null
            ? context.copyWith(stopOnFirstError: false)
            : _context.copyWith(stopOnFirstError: false);
    _validators.add(
      GeneralValidator.wrapAdvanced(AndValidator<T>(validators, relContext)),
    );

    return this as Self;
  } */

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
  StringDateNode format(String format, {String? error}) {
    _validators.add(StringDateValidator.format(format, error: error));

    return this;
  }

  /// Maximum allowed year.
  StringDateNode maxYear(int max, {String? error}) {
    _validators.add(StringDateValidator.maxYear(max, error: error));

    return this;
  }

  /// Minimum allowed year.
  StringDateNode minYear(int min, {String? error}) {
    _validators.add(StringDateValidator.minYear(min, error: error));

    return this;
  }

  /// Date must not be in the past.
  StringDateNode notPast({String? error}) {
    _validators.add(StringDateValidator.notPast(error: error));

    return this;
  }

  /// Date must not be in the future.
  StringDateNode notFuture({String? error}) {
    _validators.add(StringDateValidator.notFuture(error: error));

    return this;
  }

  /// Date must be before a certain string date.
  StringDateNode before(String date, {String? error}) {
    _validators.add(StringDateValidator.before(date, error: error));

    return this;
  }

  /// Date must be after a certain string date.
  StringDateNode after(String date, {String? error}) {
    _validators.add(StringDateValidator.after(date, error: error));

    return this;
  }

  /// Date must be within the given range.
  StringDateNode range(String start, String end, {String? error}) {
    _validators.add(StringDateValidator.range(start, end, error: error));

    return this;
  }

  /// Requires the date to be a leap year.
  StringDateNode leapYear({String? error}) {
    _validators.add(StringDateValidator.leapYear(error: error));

    return this;
  }

  /// Validates ISO 8601 format.
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

  /// Minimum allowed value.
  NumNode<T> min(int min, {String? error}) {
    _validators.add(NumValidator.min(min, error: error));

    return this;
  }

  /// Maximum allowed value.
  NumNode<T> max(int max, {String? error}) {
    _validators.add(NumValidator.max(max, error: error));

    return this;
  }

  /// Requires a positive number (> 0).
  NumNode<T> positive({String? error}) {
    _validators.add(NumValidator.positive(error: error));

    return this;
  }

  /// Requires a negative number (< 0).
  NumNode<T> negative({String? error}) {
    _validators.add(NumValidator.negative(error: error));

    return this;
  }

  /// Requires number to be in a specific range (inclusive).
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

/// A specialized validator node for validating password strings.
///
/// Includes rules like uppercase, digits, special characters, etc.
///
/// ### Example:
/// ```dart
/// final result = Checkit.string
///   .password()
///   .min(8)
///   .hasUppercase()
///   .hasDigit()
///   .validateOnce('P@ssword1');
/// ```
class PasswordNode<T extends String> extends ValidatorNode<T, PasswordNode<T>> {
  PasswordNode(super._config);

  @override
  PasswordNode<T> clone({ValidationContext? context}) {
    final clone = PasswordNode<T>(context ?? _context);
    clone._addValidators(List.of(_validators));
    return clone;
  }

  /// Maximum number of characters.
  PasswordNode<T> max(int length, {String? error}) {
    _validators.add(StringValidator.max(length, error: error));

    return this;
  }

  /// Minimum number of characters.
  PasswordNode<T> min(int length, {String? error}) {
    _validators.add(StringValidator.min(length, error: error));

    return this;
  }

  /// Requires at least one uppercase letter (A-Z).
  PasswordNode<T> hasUppercase({String? error}) {
    _validators.add(PasswordValidator.hasUppercase(error: error));

    return this;
  }

  /// Requires at least one lowercase letter (a-z).
  PasswordNode<T> hasLowercase({String? error}) {
    _validators.add(PasswordValidator.hasLowercase(error: error));

    return this;
  }

  /// Requires at least one digit (0-9).
  PasswordNode<T> hasDigit({String? error}) {
    _validators.add(PasswordValidator.hasDigit(error: error));

    return this;
  }

  /// Requires at least one letter (A-Z or a-z).
  PasswordNode<T> hasLetter({String? error}) {
    _validators.add(PasswordValidator.hasLetter(error: error));

    return this;
  }

  /// Disallows whitespace characters.
  PasswordNode<T> noSpace({String? error}) {
    _validators.add(PasswordValidator.noSpace(error: error));

    return this;
  }

  /// Requires at least one special character.
  ///
  /// You can customize allowed characters with [allowedChars].
  PasswordNode<T> hasSpecial({String? allowedChars, String? error}) {
    _validators.add(
      PasswordValidator.hasSpecial(allowedChars: allowedChars, error: error),
    );

    return this;
  }

  /// Requires at least one character from a custom [symbols] set.
  PasswordNode<T> hasSymbols(String symbols, {String? error}) {
    _validators.add(StringValidator.hasSymbols(symbols, error: error));

    return this;
  }

  PasswordNode<T> common({String? error}) {
    _validators.addAll([
      PasswordValidator.noSpace(),
      StringValidator.min(8),
      PasswordValidator.hasLowercase(),
      PasswordValidator.hasUppercase(),
      PasswordValidator.hasDigit(),
      PasswordValidator.hasSpecial(),
    ]);

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

  /// Validates that the string's length is between [min] and [max].
  StringNode<T> range(int min, int max, {String? error}) {
    _validators.add(StringValidator.range(min, max, error: error));

    return this;
  }

  /// Validates that the string has at least [length] characters.
  StringNode<T> min(int length, {String? error}) {
    _validators.add(StringValidator.min(length, error: error));

    return this;
  }

  /// Validates that the string has no more than [length] characters.
  StringNode<T> max(int length, {String? error}) {
    _validators.add(StringValidator.max(length, error: error));

    return this;
  }

  /// Validates that the string contains at least one of the provided [symbols].
  StringNode<T> hasSymbols(String symbols, {String? error}) {
    _validators.add(StringValidator.hasSymbols(symbols, error: error));

    return this;
  }

  /// Validates that the string ends with the provided [suffix].
  StringNode<T> endsWith(String suffix, {String? error}) {
    _validators.add(StringValidator.endsWith(suffix, error: error));

    return this;
  }

  /// Validates that the string starts with the provided [prefix].
  StringNode<T> startsWith(String suffix, {String? error}) {
    _validators.add(StringValidator.startsWith(suffix, error: error));

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

  /// Requires IPv4 format (e.g. 192.168.1.1).
  IpNode<T> v4({String? error}) {
    _validators.add(IpValidator.v4(error: error));

    return this;
  }

  /// Requires IPv6 format.
  IpNode<T> v6({String? error}) {
    _validators.add(IpValidator.v6(error: error));

    return this;
  }

  /// Requires the IP to be in a given subnet (CIDR).
  IpNode<T> inSubnet(String cidr, {String? error}) {
    _validators.add(IpValidator.inSubnet(cidr, error: error));

    return this;
  }

  /// Requires the IP to be link-local.
  IpNode<T> linkLocal({String? error}) {
    _validators.add(IpValidator.linkLocal(error: error));

    return this;
  }

  /// Requires the IP to be localhost (127.0.0.1 or ::1).
  IpNode<T> localhost({String? error}) {
    _validators.add(IpValidator.localhost(error: error));

    return this;
  }

  /// Requires the IP to be a loopback address.
  IpNode<T> loopback({String? error}) {
    _validators.add(IpValidator.loopback(error: error));

    return this;
  }

  /// Requires the IP to be in a specific range.
  IpNode<T> range(String startIp, String endIp, {String? error}) {
    _validators.add(IpValidator.range(startIp, endIp, error: error));

    return this;
  }

  @override
  IpNode<T> withContext(ValidationContext context) {
    return clone(context: context);
  }
}

/// Validates that a string represents a subnet that contains a given IP.
///
/// ### Example:
/// ```dart
/// Checkit.string.subnet('192.168.0.0/24').contains('192.168.0.10');
/// ```
class SubnetNode<T extends String> extends ValidatorNode<T, SubnetNode<T>> {
  SubnetNode(super._locale);

  @override
  SubnetNode<T> clone({ValidationContext? context}) {
    final clone = SubnetNode<T>(context ?? _context);
    clone._addValidators(List.of(_validators));
    return clone;
  }

  /// Requires the subnet to contain the given [ip].
  SubnetNode<T> contains(String ip, {String? error}) {
    _validators.add(SubnetValidator.contains(ip, error: error));

    return this;
  }

  @override
  SubnetNode<T> withContext(ValidationContext context) {
    return clone(context: context);
  }
}

class DateTimeNode<T extends DateTime>
    extends ValidatorNode<T, DateTimeNode<T>> {
  DateTimeNode(super._context);

  @override
  DateTimeNode<T> clone({ValidationContext? context}) {
    final clone = DateTimeNode<T>(context ?? _context);
    clone._addValidators(List.of(_validators));
    return clone;
  }

  /// Maximum allowed year.
  DateTimeNode maxYear(int max, {String? error}) {
    _validators.add(DateTimeValidator.maxYear(max, error: error));

    return this;
  }

  /// Minimum allowed year.
  DateTimeNode minYear(int min, {String? error}) {
    _validators.add(DateTimeValidator.minYear(min, error: error));

    return this;
  }

  /// Date must not be in the past.
  DateTimeNode notPast({String? error}) {
    _validators.add(DateTimeValidator.notPast(error: error));

    return this;
  }

  /// Date must not be in the future.
  DateTimeNode notFuture({String? error}) {
    _validators.add(DateTimeValidator.notFuture(error: error));

    return this;
  }

  /// Date must be before a certain string date.
  DateTimeNode before(DateTime date, {String? error}) {
    _validators.add(DateTimeValidator.before(date, error: error));

    return this;
  }

  /// Date must be after a certain string date.
  DateTimeNode after(DateTime date, {String? error}) {
    _validators.add(DateTimeValidator.after(date, error: error));

    return this;
  }

  /// Date must be within the given range.
  DateTimeNode range(DateTime start, DateTime end, {String? error}) {
    _validators.add(DateTimeValidator.range(start, end, error: error));

    return this;
  }

  /// Requires the date to be a leap year.
  DateTimeNode leapYear({String? error}) {
    _validators.add(DateTimeValidator.leapYear(error: error));

    return this;
  }

  @override
  DateTimeNode<T> withContext(ValidationContext context) {
    return clone(context: context);
  }
}

class IntNode<T extends int> extends ValidatorNode<T, IntNode<T>> {
  IntNode(super._context);

  @override
  IntNode<T> clone({ValidationContext? context}) {
    final clone = IntNode<T>(context ?? _context);
    clone._addValidators(List.of(_validators));
    return clone;
  }

  /// Minimum allowed value.
  IntNode<T> min(int min, {String? error}) {
    _validators.add(NumValidator.min(min, error: error));

    return this;
  }

  /// Maximum allowed value.
  IntNode<T> max(int max, {String? error}) {
    _validators.add(NumValidator.max(max, error: error));

    return this;
  }

  /// Requires a positive number (> 0).
  IntNode<T> positive({String? error}) {
    _validators.add(NumValidator.positive(error: error));

    return this;
  }

  /// Requires a negative number (< 0).
  IntNode<T> negative({String? error}) {
    _validators.add(NumValidator.negative(error: error));

    return this;
  }

  /// Requires number to be in a specific range (inclusive).
  IntNode<T> range(int min, int max, {String? error}) {
    _validators.add(NumValidator.range(min, max, error: error));

    return this;
  }

  IntNode<T> digitCount(int count, {String? error}) {
    _validators.add(IntValidator.digitCount(count, error: error));

    return this;
  }

  IntNode<T> divisibleBy(int divisor, {String? error}) {
    _validators.add(IntValidator.divisibleBy(divisor, error: error));

    return this;
  }

  IntNode<T> even({String? error}) {
    _validators.add(IntValidator.even(error: error));

    return this;
  }

  IntNode<T> odd({String? error}) {
    _validators.add(IntValidator.odd(error: error));

    return this;
  }

  IntNode<T> oneOf(Set<int> allowedValues, {String? error}) {
    _validators.add(IntValidator.oneOf(allowedValues, error: error));

    return this;
  }

  IntNode<T> prime({String? error}) {
    _validators.add(IntValidator.prime(error: error));

    return this;
  }

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

class DoubleNode<T extends double> extends ValidatorNode<T, DoubleNode<T>> {
  DoubleNode(super._context);

  @override
  DoubleNode<T> clone({ValidationContext? context}) {
    final clone = DoubleNode<T>(context ?? _context);
    clone._addValidators(List.of(_validators));
    return clone;
  }

  /// Minimum allowed value.
  DoubleNode<T> min(int min, {String? error}) {
    _validators.add(NumValidator.min(min, error: error));

    return this;
  }

  /// Maximum allowed value.
  DoubleNode<T> max(int max, {String? error}) {
    _validators.add(NumValidator.max(max, error: error));

    return this;
  }

  /// Requires a positive number (> 0).
  DoubleNode<T> positive({String? error}) {
    _validators.add(NumValidator.positive(error: error));

    return this;
  }

  /// Requires a negative number (< 0).
  DoubleNode<T> negative({String? error}) {
    _validators.add(NumValidator.negative(error: error));

    return this;
  }

  /// Requires number to be in a specific range (inclusive).
  DoubleNode<T> range(int min, int max, {String? error}) {
    _validators.add(NumValidator.range(min, max, error: error));

    return this;
  }

  DoubleNode<T> decimal({String? error}) {
    _validators.add(DoubleValidator.decimal(error: error));

    return this;
  }

  DoubleNode<T> finite({String? error}) {
    _validators.add(DoubleValidator.finite(error: error));

    return this;
  }

  DoubleNode<T> integer({String? error}) {
    _validators.add(DoubleValidator.integer(error: error));

    return this;
  }

  @override
  DoubleNode<T> withContext(ValidationContext context) {
    return clone(context: context);
  }
}
