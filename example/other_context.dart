import 'package:checkit/checkit.dart';
import 'package:checkit/checkit_core.dart';

class UkNumErrors implements NumCheckitErrorsBase {
  @override
  max(num max) => "Значення має бути не більше ніж $max";

  @override
  min(num min) => "Значення має бути не менше ніж $max";

  @override
  negative() => "Значення має бути позитивним";

  @override
  positive() => "Значення має бути негативним";

  @override
  range(num min, num max, {bool includeMin = true, bool includeMax = true}) =>
      "Значення має бути не у діапазоні між $min та $max";

  @override
  multiple(num factor) => "";
}

class MyErrors implements ICheckitErrors {
  @override
  GeneralCheckitErrors get generalErrors => GeneralCheckitErrors();

  @override
  NumCheckitErrorsBase get numErrors => UkNumErrors();

  @override
  StringCheckitErrorsBase get stringErrors => StringCheckitErrors();

  @override
  StringDateCheckitErrorsBase get stringDateErrors =>
      throw StringDateCheckitErrors();

  @override
  PasswordCheckitErrorsBase get passwordErrors => PasswordCheckitErrors();

  @override
  IpCheckitErrorsBase get ipErrors => IpCheckitErrors();

  @override
  DoubleCheckitErrorsBase get doubleErrors => DoubleCheckitErrors();

  @override
  IntCheckitErrorsBase get intErrors => IntCheckitErrors();
}

void main() {
  final validator = AndValidator(
    [NumValidator.min(10), NumValidator.max(20)],
    ValidationContext(
      errors: MyErrors(),
      warnings: Warnings(),
      resources: ValidationResources(),
      caseHandling: CaseHandling.exact,
      usePermanentCache: false,
      stopOnFirstError: false,
    ),
  );

  final value = 44;
  final result = validator.validate(value);

  if (result.isValid) {
    print('Validation Passed');
  } else {
    print('Validation Failed: ${result.toMessageString()}');
  }
}
