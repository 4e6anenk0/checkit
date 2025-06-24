import 'package:checkit/src/advanced_validators/advanced_validator.dart';
import 'package:checkit/src/validation_context.dart';
import 'package:checkit/src/validation_result.dart';

import '../validators/validator.dart';

class NotValidator<T> extends AdvancedValidator<T> {
  const NotValidator(this.validator, this.context);

  final Validator validator;
  final ValidationContext context;

  @override
  ValidationResult validate(T? value) {
    if (value == null) {
      return ValidationResult.failure(['Value must not be null.']);
    }

    final (valid, error) = validator(value, context);

    if (valid) {
      return ValidationResult.failure([
        error ?? 'A validator passed, which is not allowed.',
      ]);
    }

    return ValidationResult.success();
  }

  /* @override
  ValidationResult validate(T? value, {bool stopOnFirstError = false}) {
    if (value == null) {
      return ValidationResult.failure(['Value must not be null.']);
    }

    List<String>? collectedErrors;

    for (final validator in validators) {
      final (valid, error) = validator(value, context);

      // If any validator passes, NotValidator fails
      if (valid) {
        return ValidationResult.failure([
          error ?? 'A validator passed, which is not allowed.',
        ]);
      }

      // Collect error if validator fails (for informational purposes, if needed)
      if (error != null && !stopOnFirstError) {
        collectedErrors ??= [];
        collectedErrors.add(error);
      }

      // If stopOnFirstError is true, stop after the first passing validator
      if (stopOnFirstError && valid) {
        return ValidationResult.failure([
          error ?? 'A validator passed, which is not allowed.',
        ]);
      }
    }

    return ValidationResult.success();
  } */
}
