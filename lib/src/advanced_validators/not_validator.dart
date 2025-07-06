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
}
