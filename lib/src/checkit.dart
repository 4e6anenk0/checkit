import 'package:checkit/src/errors/warnings.dart';
import 'package:checkit/src/validators/ip_validator.dart';
import 'package:checkit/src/validators/password_validator.dart';
import 'package:checkit/src/validators/subnet_validator.dart';

import 'advanced_validators/group_validators.dart';
import 'errors/errors.dart';
import 'validators/validators.dart';
import 'validation_context.dart';
import 'validation_resources.dart';
import 'validation_result.dart';

abstract class Checkit {
  static ValidatorConfig config = ValidatorConfig();

  static StringNode get string => StringNode(config.buildContext());
  static NumNode get num => NumNode(config.buildContext());
}

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

abstract class ValidatorNode<T> {
  ValidatorNode(this._context);

  final ValidationContext _context;

  final List<Validator<T>> _validators = [];

  ValidatorNode<T> not(Validator<T> validator, {String? error}) {
    _validators.add(GeneralValidator.not(validator, error: error));

    return this;
  }

  ValidatorNode or(Validator<T> validator) {
    _validators.add(
      GeneralValidator.wrapAdvanced(OrValidator<T>([validator], _context)),
    );

    return this;
  }

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

  /* void addValidator(Validator<T> validator) {
    _validators.add(validator);
  } */

  /// Быстрая проверка значений без сохранения билдера
  ValidationResult validateOnce(T? value, {bool? stopOnFirstError}) =>
      build().validate(value, stopOnFirstError: stopOnFirstError);

  /// Клонирование узла с независимыми валидаторами и контекстом
  ValidatorNode<T> clone({ValidationContext? context});

  /// Клонирование узла с новой конфигурацией
  ValidatorNode<T> withContext(ValidationContext context) {
    return clone(context: context);
  }

  ValidatorSet<T> build({ValidationContext? context}) {
    final c = context ?? _context;
    return ValidatorSet<T>(
      validators: List.unmodifiable(_validators),
      context: c,
      stopOnFirstError: c.stopOnFirstError,
    );
  }
}

class StringDateNode<T extends String> extends ValidatorNode<T> {
  StringDateNode(super._context);

  @override
  StringDateNode<T> clone({ValidationContext? context}) {
    final clone = StringDateNode<T>(context ?? _context);
    clone._addValidators(List.of(_validators));
    return clone;
  }

  StringDateNode format(String format, {String? error}) {
    _validators.add(StringDateValidator.format(format, error: error));

    return this;
  }

  StringDateNode maxYear(int max, {String? error}) {
    _validators.add(StringDateValidator.maxYear(max, error: error));

    return this;
  }

  StringDateNode minYear(int min, {String? error}) {
    _validators.add(StringDateValidator.minYear(min, error: error));

    return this;
  }

  StringDateNode notPast({String? error}) {
    _validators.add(StringDateValidator.notPast(error: error));

    return this;
  }

  StringDateNode notFuture({String? error}) {
    _validators.add(StringDateValidator.notFuture(error: error));

    return this;
  }

  StringDateNode before(String date, {String? error}) {
    _validators.add(StringDateValidator.before(date, error: error));

    return this;
  }

  StringDateNode after(String date, {String? error}) {
    _validators.add(StringDateValidator.after(date, error: error));

    return this;
  }

  StringDateNode range(String start, String end, {String? error}) {
    _validators.add(StringDateValidator.range(start, end, error: error));

    return this;
  }

  StringDateNode leapYear({String? error}) {
    _validators.add(StringDateValidator.leapYear(error: error));

    return this;
  }

  StringDateNode iso8601({String? error}) {
    _validators.add(StringDateValidator.iso8601(error: error));

    return this;
  }
}

class NumNode<T extends num> extends ValidatorNode<T> {
  NumNode(super._context);

  @override
  NumNode<T> clone({ValidationContext? context}) {
    final clone = NumNode<T>(context ?? _context);
    clone._addValidators(List.of(_validators));
    return clone;
  }

  NumNode min(int min, {String? error}) {
    _validators.add(NumValidator.min(min, error: error));

    return this;
  }

  NumNode max(int max, {String? error}) {
    _validators.add(NumValidator.max(max, error: error));

    return this;
  }

  NumNode positive({String? error}) {
    _validators.add(NumValidator.positive(error: error));

    return this;
  }

  NumNode negative({String? error}) {
    _validators.add(NumValidator.negative(error: error));

    return this;
  }

  NumNode range(int min, int max, {String? error}) {
    _validators.add(NumValidator.range(min, max, error: error));

    return this;
  }
}

class PasswordNode<T extends String> extends ValidatorNode<T> {
  PasswordNode(super._config);

  @override
  PasswordNode<T> clone({ValidationContext? context}) {
    final clone = PasswordNode<T>(context ?? _context);
    clone._addValidators(List.of(_validators));
    return clone;
  }

  PasswordNode max(int length, {String? error}) {
    _validators.add(StringValidator.max(length, error: error));

    return this;
  }

  PasswordNode min(int length, {String? error}) {
    _validators.add(StringValidator.min(length, error: error));

    return this;
  }

  PasswordNode hasUppercase({String? error}) {
    _validators.add(PasswordValidator.hasUppercase(error: error));

    return this;
  }

  PasswordNode hasLowercase({String? error}) {
    _validators.add(PasswordValidator.hasLowercase(error: error));

    return this;
  }

  PasswordNode hasDigit({String? error}) {
    _validators.add(PasswordValidator.hasDigit(error: error));

    return this;
  }

  PasswordNode hasLetter({String? error}) {
    _validators.add(PasswordValidator.hasLetter(error: error));

    return this;
  }

  PasswordNode noSpace({String? error}) {
    _validators.add(PasswordValidator.noSpace(error: error));

    return this;
  }

  PasswordNode hasSpecial({String? allowedChars, String? error}) {
    _validators.add(
      PasswordValidator.hasSpecial(allowedChars: allowedChars, error: error),
    );

    return this;
  }

  PasswordNode hasSymbols(String symbols, {String? error}) {
    _validators.add(StringValidator.hasSymbols(symbols, error: error));

    return this;
  }
}

class StringNode<T extends String> extends ValidatorNode<T> {
  StringNode(super._config);

  PasswordNode password() {
    return PasswordNode(_context);
  }

  StringDateNode dateTime(String format) {
    final stringDateNode = StringDateNode(_context);
    stringDateNode._addValidators([StringDateValidator.dateTime(format)]);
    return stringDateNode;
  }

  StringDateNode dateTimeAuto({String? preferredFormat}) {
    final stringDateNode = StringDateNode(_context);
    stringDateNode._addValidators([
      StringDateValidator.dateTimeAuto(preferredFormat: preferredFormat),
    ]);
    return stringDateNode;
  }

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

  StringNode email({String? error}) {
    _validators.add(StringValidator.email(error: error));

    return this;
  }

  StringNode range(int min, int max, {String? error}) {
    _validators.add(StringValidator.range(min, max, error: error));

    return this;
  }

  StringNode min(int length, {String? error}) {
    _validators.add(StringValidator.min(length, error: error));

    return this;
  }

  StringNode max(int length, {String? error}) {
    _validators.add(StringValidator.max(length, error: error));

    return this;
  }

  StringNode hasSymbols(String symbols, {String? error}) {
    _validators.add(StringValidator.hasSymbols(symbols, error: error));

    return this;
  }

  StringNode endsWith(String suffix, {String? error}) {
    _validators.add(StringValidator.endsWith(suffix, error: error));

    return this;
  }

  StringNode startsWith(String suffix, {String? error}) {
    _validators.add(StringValidator.startsWith(suffix, error: error));

    return this;
  }

  IpNode ip() {
    final ipNode = IpNode(_context);
    ipNode._addValidators([IpValidator.ip()]);
    return ipNode;
  }

  SubnetNode subnet(String cidr) {
    final subnetNode = SubnetNode(_context);
    subnetNode._addValidators([SubnetValidator.subnet(cidr)]);
    return subnetNode;
  }
}

class IpNode<T extends String> extends ValidatorNode<T> {
  IpNode(super._config);

  @override
  IpNode<T> clone({ValidationContext? context}) {
    final clone = IpNode<T>(context ?? _context);
    clone._addValidators(List.of(_validators));
    return clone;
  }

  IpNode v4({String? error}) {
    _validators.add(IpValidator.v4(error: error));

    return this;
  }

  IpNode v6({String? error}) {
    _validators.add(IpValidator.v6(error: error));

    return this;
  }

  IpNode inSubnet(String cidr, {String? error}) {
    _validators.add(IpValidator.inSubnet(cidr, error: error));

    return this;
  }

  IpNode linkLocal({String? error}) {
    _validators.add(IpValidator.linkLocal(error: error));

    return this;
  }

  IpNode localhost({String? error}) {
    _validators.add(IpValidator.localhost(error: error));

    return this;
  }

  IpNode loopback({String? error}) {
    _validators.add(IpValidator.loopback(error: error));

    return this;
  }

  IpNode range(String startIp, String endIp, {String? error}) {
    _validators.add(IpValidator.range(startIp, endIp, error: error));

    return this;
  }
}

class SubnetNode<T extends String> extends ValidatorNode<T> {
  SubnetNode(super._locale);

  @override
  SubnetNode<T> clone({ValidationContext? context}) {
    final clone = SubnetNode<T>(context ?? _context);
    clone._addValidators(List.of(_validators));
    return clone;
  }

  SubnetNode contains(String ip, {String? error}) {
    _validators.add(SubnetValidator.contains(ip, error: error));

    return this;
  }
}
