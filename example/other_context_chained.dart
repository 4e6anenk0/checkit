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
  positive() => "Значення  має бути негативним";

  @override
  multiple(num factor) => '';

  @override
  range(num min, num max, {bool includeMin = true, bool includeMax = true}) =>
      "Значення має бути не у діапазоні між $min та $max";
}

class EsNumErrors implements NumCheckitErrorsBase {
  @override
  max(num max) => "El valor debe ser menor o igual que $max";

  @override
  min(num min) => "El valor debe ser mayor o igual que $min";

  @override
  negative() => "El valor debe ser negativo";

  @override
  positive() => "El valor debe ser positivo";

  @override
  multiple(num factor) => '';

  @override
  range(num min, num max, {bool includeMin = true, bool includeMax = true}) =>
      "El valor debe estar entre $min y $max";
}

class UkErrors implements ICheckitErrors {
  @override
  GeneralCheckitErrors get generalErrors => GeneralCheckitErrors();

  @override
  NumCheckitErrorsBase get numErrors => UkNumErrors();

  @override
  StringCheckitErrorsBase get stringErrors => StringCheckitErrors();

  @override
  StringDateCheckitErrorsBase get stringDateErrors => StringDateCheckitErrors();

  @override
  PasswordCheckitErrorsBase get passwordErrors => PasswordCheckitErrors();

  @override
  IpCheckitErrorsBase get ipErrors => IpCheckitErrors();

  @override
  DoubleCheckitErrorsBase get doubleErrors => DoubleCheckitErrors();

  @override
  IntCheckitErrorsBase get intErrors => IntCheckitErrors();
}

class EsErrors implements ICheckitErrors {
  @override
  GeneralCheckitErrors get generalErrors => GeneralCheckitErrors();

  @override
  NumCheckitErrorsBase get numErrors => EsNumErrors();

  @override
  StringCheckitErrorsBase get stringErrors => StringCheckitErrors();

  @override
  StringDateCheckitErrorsBase get stringDateErrors => StringDateCheckitErrors();

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
  Checkit.config = ValidatorConfig().copyWith(
    errors: UkErrors(),
  ); // top level configuration
  final validatorBuilder = Checkit.num.min(10).max(20);

  final ukValidator = validatorBuilder.build();

  //validator.setContext(ValidationContext.withLocale(locale));

  final value = 44;
  final result = ukValidator.validate(value);

  if (result.isValid) {
    print('Validation Passed');
  } else {
    print('Validation Failed: ${result.toMessageString()}');
  }

  final esValidator = validatorBuilder.build(
    context: ValidationContext.defaultContext().copyWith(
      errors: EsErrors(),
    ), // override context
  );

  final result2 = esValidator.validate(value);

  if (result.isValid) {
    print('Validation Passed');
  } else {
    print('Validation Failed: ${result2.toMessageString()}');
  }
}
