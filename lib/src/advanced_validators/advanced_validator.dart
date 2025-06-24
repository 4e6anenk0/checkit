import '../validation_result.dart';

abstract class AdvancedValidator<T> {
  const AdvancedValidator();

  ValidationResult validate(T? value);

  @override
  bool operator ==(Object other);

  @override
  int get hashCode;
}
