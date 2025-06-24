import '../validation_result.dart';
import '../validators/validator.dart';
import 'advanced_validator.dart';

class CustomValidator<T> extends AdvancedValidator<T> {
  final Validator<T> validator;

  const CustomValidator(this.validator);

  @override
  ValidationResult validate(T? value) {
    validator
  }
  @override
  bool operator ==(Object other) =>
      other is CustomValidator<T> && other.min == min;

  @override
  int get hashCode => min.hashCode;
}
