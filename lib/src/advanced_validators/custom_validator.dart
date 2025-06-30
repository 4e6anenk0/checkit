import 'package:checkit/src/validation_context.dart';

import '../validation_result.dart';
import '../validators/validator.dart';
import 'advanced_validator.dart';

class CustomValidator<T> extends AdvancedValidator<T> {
  final Validator<T> validator;
  final ValidationContext context;

  const CustomValidator(this.validator, this.context);

  @override
  ValidationResult validate(T? value) {
    if (value == null) {
      return ValidationResult.failure(['Value must not be null.']);
    }

    return ValidationResult.single(validator(value, context).$2);
  }
}
