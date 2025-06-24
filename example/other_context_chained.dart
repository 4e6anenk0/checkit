import 'package:checkit/checkit.dart';

class UkNumErrors implements NumCheckitErrorsBase {
  @override
  max(int max) => "Значення має бути не більше ніж $max";

  @override
  min(int min) => "Значення має бути не менше ніж $max";

  @override
  negative() => "Значення має бути позитивним";

  @override
  positive() => "Значення  має бути негативним";

  @override
  range(int min, int max) =>
      "Значення має бути не у діапазоні між $min та $max";
}

class EsNumErrors implements NumCheckitErrorsBase {
  @override
  max(int max) => "El valor debe ser menor o igual que $max";

  @override
  min(int min) => "El valor debe ser mayor o igual que $min";

  @override
  negative() => "El valor debe ser negativo";

  @override
  positive() => "El valor debe ser positivo";

  @override
  range(int min, int max) => "El valor debe estar entre $min y $max";
}

class UkErrors implements CheckitErrorsBase {
  @override
  GeneralCheckitErrors get generalErrors => GeneralCheckitErrors();

  @override
  String get locale => 'uk';

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
}

class EsErrors implements CheckitErrorsBase {
  @override
  GeneralCheckitErrors get generalErrors => GeneralCheckitErrors();

  @override
  String get locale => 'es';

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
}

void main() {
  final validatorBuilder = Checkit.num.min(10).max(20);

  validatorBuilder.addLocale(UkErrors());
  validatorBuilder.addLocale(EsErrors());

  validatorBuilder.setLocale('uk');

  final ukValidator = validatorBuilder.build();

  //validator.setContext(ValidationContext.withLocale(locale));

  final value = 44;
  final result = ukValidator.validate(value);

  if (result.isValid) {
    print('Validation Passed');
  } else {
    print('Validation Failed: ${result.toMessageString()}');
  }

  validatorBuilder.setLocale('es');

  final esValidator = validatorBuilder.build();

  final result2 = esValidator.validate(value);

  if (result.isValid) {
    print('Validation Passed');
  } else {
    print('Validation Failed: ${result2.toMessageString()}');
  }
}
