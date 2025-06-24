import '../validation_context.dart';
import '../validation_result.dart';
import '../validators/validator.dart';
import 'advanced_validator.dart';

abstract class CompositeValidator<T> extends AdvancedValidator<T> {
  final List<Validator<T>> validators;
  final ValidationContext context;

  const CompositeValidator(this.validators, this.context);

  void add(Validator<T> validator) {
    validators.add(validator);
  }

  void addAll(List<Validator<T>> validators) {
    validators.addAll(validators);
  }
}

class AndValidator<T> extends CompositeValidator<T> {
  const AndValidator(super.validators, super.context);

  @override
  ValidationResult validate(T? value, {bool stopOnFirstError = false}) {
    if (value == null) {
      return ValidationResult.failure(['Value must not be null.']);
    }

    List<String>? collectedErrors;

    for (final validator in validators) {
      final (valid, error) = validator(value, context);

      if (!valid && error != null) {
        if (stopOnFirstError) {
          return ValidationResult.failure([error]);
        }
        collectedErrors ??= [];
        collectedErrors.add(error);
      }
    }

    if (collectedErrors == null) {
      return ValidationResult.success();
    }

    final errors = List.generate(
      collectedErrors.length,
      (i) => collectedErrors![i],

      growable: false,
    );

    return ValidationResult.failure(errors);
  }
}

class OrValidator<T> extends CompositeValidator<T> {
  OrValidator(super.validators, super.context);

  @override
  ValidationResult validate(T? value, {bool stopOnFirstError = false}) {
    if (value == null) {
      return ValidationResult.failure(['Value must not be null.']);
    }

    List<String>? collectedErrors;

    for (final validator in validators) {
      final (valid, error) = validator(value, context);

      // If any validator passes, return success immediately
      if (valid) {
        return ValidationResult.success();
      }

      // Collect error if validator fails
      if (error != null) {
        collectedErrors ??= [];
        collectedErrors.add(error);
      }

      // If stopOnFirstError is true, we can stop after the first failure
      // since we know no validator has passed yet
      if (stopOnFirstError && collectedErrors != null) {
        return ValidationResult.failure([collectedErrors.first]);
      }
    }

    // If no validators passed, return all collected errors
    if (collectedErrors == null || collectedErrors.isEmpty) {
      return ValidationResult.failure(['No validators passed.']);
    }

    final errors = List.generate(
      collectedErrors.length,
      (i) => collectedErrors![i],
      growable: false,
    );

    return ValidationResult.failure(errors);
  }
}

class NotValidator<T> extends CompositeValidator<T> {
  const NotValidator(super.validators, super.context);

  @override
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
  }
}
