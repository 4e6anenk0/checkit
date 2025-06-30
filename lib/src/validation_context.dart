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
  final ICheckitErrors errors;
  final Warnings warnings;
  final ValidationResourcesBase resources;
  final CaseHandling caseHandling;
  final bool usePermanentCache;
  final bool stopOnFirstError;

  const ValidationContext({
    required this.errors,
    required this.warnings,
    required this.resources,
    required this.caseHandling,
    required this.usePermanentCache,
    required this.stopOnFirstError,
  });

  factory ValidationContext.defaultContext() => ValidationContext(
    errors: const CheckitErrors(
      stringErrors: StringCheckitErrors(),
      generalErrors: GeneralCheckitErrors(),
      numErrors: NumCheckitErrors(),
      stringDateErrors: StringDateCheckitErrors(),
      passwordErrors: PasswordCheckitErrors(),
      ipErrors: IpCheckitErrors(),
    ),
    warnings: Warnings(),
    resources: ValidationResources(),
    caseHandling: CaseHandling.exact,
    usePermanentCache: false,
    stopOnFirstError: false,
  );

  ValidationContext copyWith({
    ICheckitErrors? errors,
    Warnings? warnings,
    ValidationResourcesBase? resources,
    CaseHandling? caseHandling,
  }) {
    return ValidationContext(
      errors: errors ?? this.errors,
      warnings: warnings ?? this.warnings,
      resources: resources ?? this.resources,
      caseHandling: caseHandling ?? this.caseHandling,
      usePermanentCache: false,
      stopOnFirstError: false,
    );
  }
}
