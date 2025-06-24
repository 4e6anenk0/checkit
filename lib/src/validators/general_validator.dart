import 'package:checkit/src/advanced_validators/advanced_validator.dart';
import 'package:checkit/src/validation_context.dart';

import 'validator.dart';

abstract class GeneralValidator {
  static Validator<Object?> notNull({String? error}) => (value, context) {
    if (value != null) return (true, null);
    return (false, error ?? context.errors.generalErrors.notNull());
  };

  static Validator<Object?> wrapAdvanced(
    AdvancedValidator validator, {
    String? error,
  }) => (value, context) {
    final result = validator.validate(value);
    if (result.isValid) return (true, null);
    return (false, error ?? result.errors.join('\n'));
  };

  static Validator<T> not<T>(Validator<T> validator, {String? error}) => (
    value,
    context,
  ) {
    if (validator(value, context).$1 == false) return (true, null);
    return (false, error ?? 'A validator passed, which is not allowed');
  };

  static Validator<T> custom<T>(
    bool Function(T value, ValidationContext context) validate, {
    String error = '',
  }) => (value, context) {
    if (validate(value, context)) return (true, null);
    return (false, error);
  };
}
