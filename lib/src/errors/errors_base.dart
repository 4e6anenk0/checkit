import 'general_errors.dart';
import 'ip_errors.dart';
import 'num_errors.dart';
import 'password_errors.dart';
import 'string_date_errors.dart';
import 'string_errors.dart';

abstract interface class ICheckitErrors {
  StringCheckitErrorsBase get stringErrors;
  NumCheckitErrorsBase get numErrors;
  IpCheckitErrorsBase get ipErrors;
  PasswordCheckitErrorsBase get passwordErrors;
  StringDateCheckitErrorsBase get stringDateErrors;
  GeneralCheckitErrorsBase get generalErrors;
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

  const CheckitErrors({
    required this.stringErrors,
    required this.numErrors,
    required this.ipErrors,
    required this.passwordErrors,
    required this.stringDateErrors,
    required this.generalErrors,
  });

  factory CheckitErrors.defaultErrors() => const CheckitErrors(
    stringErrors: StringCheckitErrors(),
    numErrors: NumCheckitErrors(),
    ipErrors: IpCheckitErrors(),
    passwordErrors: PasswordCheckitErrors(),
    stringDateErrors: StringDateCheckitErrors(),
    generalErrors: GeneralCheckitErrors(),
  );

  CheckitErrors copyWith({
    StringCheckitErrorsBase? stringErrors,
    NumCheckitErrorsBase? numErrors,
    IpCheckitErrorsBase? ipErrors,
    PasswordCheckitErrorsBase? passwordErrors,
    StringDateCheckitErrorsBase? stringDateErrors,
    GeneralCheckitErrorsBase? generalErrors,
  }) {
    return CheckitErrors(
      stringErrors: stringErrors ?? this.stringErrors,
      numErrors: numErrors ?? this.numErrors,
      ipErrors: ipErrors ?? this.ipErrors,
      passwordErrors: passwordErrors ?? this.passwordErrors,
      stringDateErrors: stringDateErrors ?? this.stringDateErrors,
      generalErrors: generalErrors ?? this.generalErrors,
    );
  }
}
