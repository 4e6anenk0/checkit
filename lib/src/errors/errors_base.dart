import 'errors.dart';

abstract interface class ICheckitErrors {
  StringCheckitErrorsBase get stringErrors;
  NumCheckitErrorsBase get numErrors;
  IpCheckitErrorsBase get ipErrors;
  PasswordCheckitErrorsBase get passwordErrors;
  StringDateCheckitErrorsBase get stringDateErrors;
  GeneralCheckitErrorsBase get generalErrors;
  IntCheckitErrorsBase get intErrors;
  DoubleCheckitErrorsBase get doubleErrors;
}

class CheckitErrors implements ICheckitErrors {
  @override
  final StringCheckitErrorsBase stringErrors;
  @override
  final NumCheckitErrorsBase numErrors;
  @override
  final IpCheckitErrorsBase ipErrors;
  @override
  final PasswordCheckitErrorsBase passwordErrors;
  @override
  final StringDateCheckitErrorsBase stringDateErrors;
  @override
  final GeneralCheckitErrorsBase generalErrors;
  @override
  final IntCheckitErrorsBase intErrors;
  @override
  final DoubleCheckitErrorsBase doubleErrors;

  const CheckitErrors({
    required this.stringErrors,
    required this.numErrors,
    required this.ipErrors,
    required this.passwordErrors,
    required this.stringDateErrors,
    required this.generalErrors,
    required this.intErrors,
    required this.doubleErrors,
  });

  factory CheckitErrors.defaultErrors() => const CheckitErrors(
        stringErrors: StringCheckitErrors(),
        numErrors: NumCheckitErrors(),
        ipErrors: IpCheckitErrors(),
        passwordErrors: PasswordCheckitErrors(),
        stringDateErrors: StringDateCheckitErrors(),
        generalErrors: GeneralCheckitErrors(),
        intErrors: IntCheckitErrors(),
        doubleErrors: DoubleCheckitErrors(),
      );

  CheckitErrors copyWith({
    StringCheckitErrorsBase? stringErrors,
    NumCheckitErrorsBase? numErrors,
    IpCheckitErrorsBase? ipErrors,
    PasswordCheckitErrorsBase? passwordErrors,
    StringDateCheckitErrorsBase? stringDateErrors,
    GeneralCheckitErrorsBase? generalErrors,
    IntCheckitErrorsBase? intErrors,
    DoubleCheckitErrorsBase? doubleErrors,
  }) {
    return CheckitErrors(
      stringErrors: stringErrors ?? this.stringErrors,
      numErrors: numErrors ?? this.numErrors,
      ipErrors: ipErrors ?? this.ipErrors,
      passwordErrors: passwordErrors ?? this.passwordErrors,
      stringDateErrors: stringDateErrors ?? this.stringDateErrors,
      generalErrors: generalErrors ?? this.generalErrors,
      intErrors: intErrors ?? this.intErrors,
      doubleErrors: doubleErrors ?? this.doubleErrors,
    );
  }
}
