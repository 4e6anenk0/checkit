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
abstract class ValidatorNode<T> {
  ValidatorNode(this._context);

  final ValidationContext _context;

  final List<Validator<T>> _validators = [];

  /// Negates another validator.
  ValidatorNode<T> not(Validator<T> validator, {String? error}) {
    _validators.add(GeneralValidator.not(validator, error: error));

    return this;
  }

  /// Combines this validator with another using logical OR.
  ValidatorNode or(Validator<T> validator) {
    _validators.add(
      GeneralValidator.wrapAdvanced(OrValidator<T>([validator], _context)),
    );

    return this;
  }

  /// Adds a custom validator using a function.
  ValidatorNode custom(
    bool Function(T value, ValidationContext context) validate, {
    String error = '',
  }) {
    _validators.add(GeneralValidator.custom(validate, error: error));
    return this;
  }

  void _addValidators(List<Validator<T>> validators) {
    _validators.addAll(validators);
  }

  /// Quick validation without manually building the set.
  ValidationResult validateOnce(T? value, {bool? stopOnFirstError}) =>
      build().validate(value, stopOnFirstError: stopOnFirstError);

  /// Clones this node with an optional different context.
  ValidatorNode<T> clone({ValidationContext? context});

  /// Shortcut to clone with updated context.
  ValidatorNode<T> withContext(ValidationContext context) {
    return clone(context: context);
  }

  /// Finalizes the validator into a reusable set.
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
/// Example:
/// ```dart
/// Checkit.string
///   .dateTime('yyyy-MM-dd')
///   .notFuture()
///   .minYear(2000);
/// ```
class StringDateNode<T extends String> extends ValidatorNode<T> {
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
}

/// Fluent validator for `num` values (int/double).
///
/// Supports range, positivity, etc.
///
/// Example:
/// ```dart
/// Checkit.num.min(1).max(10).validateOnce(5);
/// ```
class NumNode<T extends num> extends ValidatorNode<T> {
  NumNode(super._context);

  @override
  NumNode<T> clone({ValidationContext? context}) {
    final clone = NumNode<T>(context ?? _context);
    clone._addValidators(List.of(_validators));
    return clone;
  }

  /// Minimum allowed value.
  NumNode min(int min, {String? error}) {
    _validators.add(NumValidator.min(min, error: error));

    return this;
  }

  /// Maximum allowed value.
  NumNode max(int max, {String? error}) {
    _validators.add(NumValidator.max(max, error: error));

    return this;
  }

  /// Requires a positive number (> 0).
  NumNode positive({String? error}) {
    _validators.add(NumValidator.positive(error: error));

    return this;
  }

  /// Requires a negative number (< 0).
  NumNode negative({String? error}) {
    _validators.add(NumValidator.negative(error: error));

    return this;
  }

  /// Requires number to be in a specific range (inclusive).
  NumNode range(int min, int max, {String? error}) {
    _validators.add(NumValidator.range(min, max, error: error));

    return this;
  }
}

/// A specialized validator node for validating password strings.
///
/// Includes rules like uppercase, digits, special characters, etc.
///
/// Example:
/// ```dart
/// final result = Checkit.string
///   .password()
///   .min(8)
///   .hasUppercase()
///   .hasDigit()
///   .validateOnce('P@ssword1');
/// ```
class PasswordNode<T extends String> extends ValidatorNode<T> {
  PasswordNode(super._config);

  @override
  PasswordNode<T> clone({ValidationContext? context}) {
    final clone = PasswordNode<T>(context ?? _context);
    clone._addValidators(List.of(_validators));
    return clone;
  }

  /// Minimum number of characters.
  PasswordNode max(int length, {String? error}) {
    _validators.add(StringValidator.max(length, error: error));

    return this;
  }

  /// Maximum number of characters.
  PasswordNode min(int length, {String? error}) {
    _validators.add(StringValidator.min(length, error: error));

    return this;
  }

  /// Requires at least one uppercase letter (A-Z).
  PasswordNode hasUppercase({String? error}) {
    _validators.add(PasswordValidator.hasUppercase(error: error));

    return this;
  }

  /// Requires at least one lowercase letter (a-z).
  PasswordNode hasLowercase({String? error}) {
    _validators.add(PasswordValidator.hasLowercase(error: error));

    return this;
  }

  /// Requires at least one digit (0-9).
  PasswordNode hasDigit({String? error}) {
    _validators.add(PasswordValidator.hasDigit(error: error));

    return this;
  }

  /// Requires at least one letter (A-Z or a-z).
  PasswordNode hasLetter({String? error}) {
    _validators.add(PasswordValidator.hasLetter(error: error));

    return this;
  }

  /// Disallows whitespace characters.
  PasswordNode noSpace({String? error}) {
    _validators.add(PasswordValidator.noSpace(error: error));

    return this;
  }

  /// Requires at least one special character.
  ///
  /// You can customize allowed characters with [allowedChars].
  PasswordNode hasSpecial({String? allowedChars, String? error}) {
    _validators.add(
      PasswordValidator.hasSpecial(allowedChars: allowedChars, error: error),
    );

    return this;
  }

  /// Requires at least one character from a custom [symbols] set.
  PasswordNode hasSymbols(String symbols, {String? error}) {
    _validators.add(StringValidator.hasSymbols(symbols, error: error));

    return this;
  }
}

/// A fluent builder for validating `String` values.
///
/// Use this class via `Checkit.string` to compose validations in a readable, chained style.
///
/// Example:
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
class StringNode<T extends String> extends ValidatorNode<T> {
  StringNode(super._config);

  /// Returns a [PasswordNode] with password-specific validation rules.
  ///
  /// Example:
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
  /// Example:
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
  /// Example:
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
  StringNode email({String? error}) {
    _validators.add(StringValidator.email(error: error));

    return this;
  }

  /// Validates that the string's length is between [min] and [max].
  StringNode range(int min, int max, {String? error}) {
    _validators.add(StringValidator.range(min, max, error: error));

    return this;
  }

  /// Validates that the string has at least [length] characters.
  StringNode min(int length, {String? error}) {
    _validators.add(StringValidator.min(length, error: error));

    return this;
  }

  /// Validates that the string has no more than [length] characters.
  StringNode max(int length, {String? error}) {
    _validators.add(StringValidator.max(length, error: error));

    return this;
  }

  /// Validates that the string contains at least one of the provided [symbols].
  StringNode hasSymbols(String symbols, {String? error}) {
    _validators.add(StringValidator.hasSymbols(symbols, error: error));

    return this;
  }

  /// Validates that the string ends with the provided [suffix].
  StringNode endsWith(String suffix, {String? error}) {
    _validators.add(StringValidator.endsWith(suffix, error: error));

    return this;
  }

  /// Validates that the string starts with the provided [prefix].
  StringNode startsWith(String suffix, {String? error}) {
    _validators.add(StringValidator.startsWith(suffix, error: error));

    return this;
  }

  /// Switches to IP-specific validation rules.
  ///
  /// Example:
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
  /// Example:
  /// ```dart
  /// Checkit.string.subnet('192.168.1.0/24').contains('192.168.1.10');
  /// ```
  SubnetNode subnet(String cidr) {
    final subnetNode = SubnetNode(_context);
    subnetNode._addValidators([SubnetValidator.subnet(cidr)]);
    return subnetNode;
  }
}

/// Validates that a string represents a valid IP address.
///
/// Supports v4/v6, local, range, and subnet checks.
///
/// Example:
/// ```dart
/// Checkit.string.ip().v4().validateOnce('192.168.1.1');
/// ```
class IpNode<T extends String> extends ValidatorNode<T> {
  IpNode(super._config);

  @override
  IpNode<T> clone({ValidationContext? context}) {
    final clone = IpNode<T>(context ?? _context);
    clone._addValidators(List.of(_validators));
    return clone;
  }

  /// Requires IPv4 format (e.g. 192.168.1.1).
  IpNode v4({String? error}) {
    _validators.add(IpValidator.v4(error: error));

    return this;
  }

  /// Requires IPv6 format.
  IpNode v6({String? error}) {
    _validators.add(IpValidator.v6(error: error));

    return this;
  }

  /// Requires the IP to be in a given subnet (CIDR).
  IpNode inSubnet(String cidr, {String? error}) {
    _validators.add(IpValidator.inSubnet(cidr, error: error));

    return this;
  }

  /// Requires the IP to be link-local.
  IpNode linkLocal({String? error}) {
    _validators.add(IpValidator.linkLocal(error: error));

    return this;
  }

  /// Requires the IP to be localhost (127.0.0.1 or ::1).
  IpNode localhost({String? error}) {
    _validators.add(IpValidator.localhost(error: error));

    return this;
  }

  /// Requires the IP to be a loopback address.
  IpNode loopback({String? error}) {
    _validators.add(IpValidator.loopback(error: error));

    return this;
  }

  /// Requires the IP to be in a specific range.
  IpNode range(String startIp, String endIp, {String? error}) {
    _validators.add(IpValidator.range(startIp, endIp, error: error));

    return this;
  }
}

/// Validates that a string represents a subnet that contains a given IP.
///
/// Example:
/// ```dart
/// Checkit.string.subnet('192.168.0.0/24').contains('192.168.0.10');
/// ```
class SubnetNode<T extends String> extends ValidatorNode<T> {
  SubnetNode(super._locale);

  @override
  SubnetNode<T> clone({ValidationContext? context}) {
    final clone = SubnetNode<T>(context ?? _context);
    clone._addValidators(List.of(_validators));
    return clone;
  }

  /// Requires the subnet to contain the given [ip].
  SubnetNode contains(String ip, {String? error}) {
    _validators.add(SubnetValidator.contains(ip, error: error));

    return this;
  }
}
