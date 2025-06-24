import 'package:checkit/src/errors/warnings.dart';

import 'errors/errors.dart';
import 'validation_resources.dart';

/// Specifies how case is handled during string validation.
enum CaseHandling {
  /// Validation requires an exact match, considering casing (e.g., "Hello" is not equal to "hello").
  exact,

  /// Validation ignores casing, treating uppercase and lowercase letters as the same (e.g., "Hello" is equal to "hello").
  ignore,
}

class ValidationContext {
  final String locale;
  final CheckitErrorsBase errors;
  final Warnings warnings;
  final ValidationResourcesBase resources;
  final CaseHandling caseHandling;

  const ValidationContext({
    required this.locale,
    required this.errors,
    required this.warnings,
    required this.resources,
    required this.caseHandling,
  });

  factory ValidationContext.defaultContext() => ValidationContext(
    locale: 'en',
    errors: const CheckitErrorsBase(
      stringErrors: StringCheckitErrors(),
      generalErrors: GeneralCheckitErrors(),
      numErrors: NumCheckitErrors(),
      stringDateErrors: StringDateCheckitErrors(),
      passwordErrors: PasswordCheckitErrors(),
      ipErrors: IpCheckitErrors(),
      locale: 'en',
    ),
    warnings: Warnings(),
    resources: ValidationResources(),
    caseHandling: CaseHandling.exact,
  );

  factory ValidationContext.withLocale(LocaleGroup locale) => ValidationContext(
    locale: locale.defaultLocaleKey,
    errors: locale.getDefault(),
    warnings: Warnings(),
    resources: ValidationResources(),
    caseHandling: CaseHandling.exact,
  );

  static get defaultErrors => const CheckitErrorsBase(
    stringErrors: StringCheckitErrors(),
    generalErrors: GeneralCheckitErrors(),
    numErrors: NumCheckitErrors(),
    stringDateErrors: StringDateCheckitErrors(),
    passwordErrors: PasswordCheckitErrors(),
    ipErrors: IpCheckitErrors(),
    locale: 'en',
  );

  ValidationContext copyWith({
    String? locale,
    CheckitErrorsBase? errors,
    Warnings? warnings,
    ValidationResourcesBase? resources,
    CaseHandling? caseHandling,
  }) {
    return ValidationContext(
      locale: locale ?? this.locale,
      errors: errors ?? this.errors,
      warnings: warnings ?? this.warnings,
      resources: resources ?? this.resources,
      caseHandling: caseHandling ?? this.caseHandling,
    );
  }
}
