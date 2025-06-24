import 'package:checkit/src/validators/ip_validator.dart';
import 'package:checkit/src/validators/password_validator.dart';

import 'advanced_validators/group_validators.dart';
import 'errors/errors.dart';
import 'validators/validators.dart';
import 'validation_context.dart';
import 'validation_resources.dart';
import 'validation_result.dart';

abstract class Checkit {
  static LocaleGroup locale = LocaleGroup();
  static StringNode get string => StringNode(locale);
  static NumNode get num => NumNode(locale);
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

  ValidationResult validate(T value, {bool? stopOnFirstError}) {
    context.resources.clear();
    final validator = AndValidator(validators, context);
    return validator.validate(
      value,
      stopOnFirstError: stopOnFirstError ?? this.stopOnFirstError,
    );
  }
}

abstract class ValidatorNode<T> {
  ValidatorNode(this._locale);

  final LocaleGroup _locale;
  final List<Validator<T>> _validators = [];
  ValidationContext _context = ValidationContext.defaultContext();
  bool stopOnFirstError = false;

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

  void setContext(ValidationContext context) {
    _context = context;
    _locale.changeLocale(context.locale);
  }

  void addLocale(CheckitErrorsBase locale) {
    _locale.addLocale(locale);
  }

  void setLocale(String locale) {
    _locale.changeLocale(locale);
    _updateContext(
      locale: _locale.defaultLocaleKey,
      errors: _locale.getDefault(),
    );
  }

  void setResource(ValidationResources resources) {
    _updateContext(resources: resources);
  }

  void _updateContext({
    String? locale,
    CheckitErrorsBase? errors,
    ValidationResourcesBase? resources,
  }) {
    _context = _context.copyWith(
      locale: locale,
      errors: errors,
      resources: resources,
    );
  }

  void addValidators(List<Validator<T>> validators) {
    _validators.addAll(validators);
  }

  void clearNode() {
    _validators.clear();
  }

  /// Быстрая проверка значений без сохранения билдера
  ValidationResult validateOnce(T value, {bool? stopOnFirstError}) =>
      build().validate(value, stopOnFirstError: stopOnFirstError);

  /// Клонирование узла с независимыми валидаторами и контекстом
  ValidatorNode<T> clone();

  ValidatorSet<T> build() {
    return ValidatorSet<T>(
      validators: List.unmodifiable(_validators),
      context: _context,
      stopOnFirstError: stopOnFirstError,
    );
  }
}

class IpNode<T extends String> extends ValidatorNode<T> {
  IpNode(super.locale);

  @override
  IpNode<T> clone() {
    final clone = IpNode<T>(_locale);
    clone.addValidators(List.of(_validators));
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
}

class StringDateNode<T extends String> extends ValidatorNode<T> {
  StringDateNode(super.locale);

  @override
  StringDateNode<T> clone() {
    final clone = StringDateNode<T>(_locale);
    clone.addValidators(List.of(_validators));
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
  NumNode(super.locale);

  @override
  NumNode<T> clone() {
    final clone = NumNode<T>(_locale);
    clone.addValidators(List.of(_validators));
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
  PasswordNode(super._locale);

  @override
  PasswordNode<T> clone() {
    final clone = PasswordNode<T>(_locale);
    clone.addValidators(List.of(_validators));
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
  StringNode(super.locale);

  PasswordNode password() {
    return PasswordNode(_locale);
  }

  StringDateNode dateTime(String format) {
    final stringDateNode = StringDateNode(_locale);
    stringDateNode.addValidators([StringDateValidator.dateTime(format)]);
    return stringDateNode;
  }

  StringDateNode dateTimeAuto({String? preferredFormat}) {
    final stringDateNode = StringDateNode(_locale);
    stringDateNode.addValidators([
      StringDateValidator.dateTimeAuto(preferredFormat: preferredFormat),
    ]);
    return stringDateNode;
  }

  StringDateNode dateTimeIso() {
    final stringDateNode = StringDateNode(_locale);
    stringDateNode.addValidators([StringDateValidator.dateTimeIso()]);
    return stringDateNode;
  }

  @override
  StringNode<T> clone() {
    final clone = StringNode<T>(_locale);
    clone.addValidators(List.of(_validators));
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
    final ipNode = IpNode(_locale);
    ipNode.addValidators([IpValidator.ip()]);
    return ipNode;
  }
}
