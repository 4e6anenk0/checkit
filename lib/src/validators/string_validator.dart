import 'package:checkit/src/validation_context.dart';

import 'validator.dart';

abstract class StringValidator {
  static Validator<String> email({String? error}) => (value, context) {
    if (context.resources.emailPattern.hasMatch(value)) {
      return (true, null);
    }
    return (false, error ?? context.errors.stringErrors.email());
  };

  static Validator<String> range(int min, int max, {String? error}) => (
    value,
    context,
  ) {
    if (value.length >= min && value.length <= max) return (true, null);
    return (false, error ?? context.errors.stringErrors.range(min, max));
  };

  static Validator<String> min(int length, {String? error}) => (
    value,
    context,
  ) {
    if (value.length > length) return (true, null);
    return (false, error ?? context.errors.stringErrors.min(length));
  };

  static Validator<String> max(int length, {String? error}) => (
    value,
    context,
  ) {
    if (value.length < length) return (true, null);
    return (false, error ?? context.errors.stringErrors.max(length));
  };

  static Validator<String> exact(int length, {String? error}) => (
    value,
    context,
  ) {
    if (value.length == length) return (true, null);
    return (false, error ?? context.errors.stringErrors.exact(length));
  };

  static Validator<String> alpha({String? error}) => (value, context) {
    if (context.resources.alphaPattern.hasMatch(value)) return (true, null);
    return (false, error ?? context.errors.stringErrors.alpha());
  };

  static Validator<String> alphanumeric({String? error}) => (value, context) {
    if (context.resources.alphanumericPattern.hasMatch(value)) {
      return (true, null);
    }
    return (false, error ?? context.errors.stringErrors.alphanumeric());
  };

  static Validator<String> contains(String data, {String? error}) => (
    value,
    context,
  ) {
    final bool contains =
        context.caseHandling == CaseHandling.ignore
            ? value.toLowerCase().contains(data.toLowerCase())
            : value.contains(data);
    if (contains) return (true, null);
    return (false, error ?? context.errors.stringErrors.contains(data));
  };

  static Validator<String> isDouble({String? error}) => (value, context) {
    if (double.tryParse(value) != null) {
      return (true, null);
    }
    return (false, error ?? context.errors.stringErrors.isDouble());
  };

  static Validator<String> isInt({String? error}) => (value, context) {
    if (int.tryParse(value) != null) {
      return (true, null);
    }
    return (false, error ?? context.errors.stringErrors.isInt());
  };

  static Validator<String> jwt({String? error}) => (value, context) {
    if (context.resources.jwtPattern.hasMatch(value)) {
      return (true, null);
    }
    return (false, error ?? context.errors.stringErrors.jwt());
  };

  static Validator<String> pattern(String pattern, {String? error}) => (
    value,
    context,
  ) {
    if (RegExp(pattern).hasMatch(value)) {
      return (true, null);
    }
    return (false, error ?? context.errors.stringErrors.jwt());
  };

  static Validator<String> equals(String expectedString, {String? error}) => (
    value,
    context,
  ) {
    final bool isEqual =
        context.caseHandling == CaseHandling.ignore
            ? value.toLowerCase() == expectedString.toLowerCase()
            : value == expectedString;
    if (isEqual) return (true, null);
    return (false, error ?? context.errors.stringErrors.equals(expectedString));
  };

  static Validator<String> hasSymbols(String symbols, {String? error}) => (
    value,
    context,
  ) {
    if (symbols.split('').every((c) => value.contains(c))) {
      return (true, null);
    }
    return (false, error ?? context.errors.stringErrors.hasSymbols(symbols));
  };

  static Validator<String> endsWith(String suffix, {String? error}) => (
    value,
    context,
  ) {
    final bool isEndsWith =
        context.caseHandling == CaseHandling.ignore
            ? value.toLowerCase().endsWith(suffix)
            : value.endsWith(suffix);
    if (isEndsWith) return (true, null);
    return (false, error ?? context.errors.stringErrors.endsWith(suffix));
  };

  static Validator<String> startsWith(String suffix, {String? error}) => (
    value,
    context,
  ) {
    final bool isStartWith =
        context.caseHandling == CaseHandling.ignore
            ? value.toLowerCase().startsWith(suffix)
            : value.startsWith(suffix);
    if (isStartWith) return (true, null);
    return (false, error ?? context.errors.stringErrors.startsWith(suffix));
  };
}
