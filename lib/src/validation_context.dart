import 'errors/errors.dart';
import 'errors/warnings.dart';
import 'validation_resources.dart';

/// Specifies how case is handled during string validation.
enum CaseHandling {
  /// Validation requires an exact match, considering casing (e.g., "Hello" is not equal to "hello").
  exact,

  /// Validation ignores casing, treating uppercase and lowercase letters as the same (e.g., "Hello" is equal to "hello").
  ignore,
}

class ValidationContext {
  /// The error message providers used by validators.
  ///
  /// You can use the default English messages (`CheckitErrors`) or provide
  /// your own implementation to support i18n or customization.
  ///
  /// Default: English error messages.
  final ICheckitErrors errors;

  /// The warning providers used for supplementary messages or notices.
  ///
  /// Default: Empty `Warnings` object.
  final Warnings warnings;

  /// Additional resources that can be used during validation.
  ///
  /// Typically includes formatters, date/time parsing tools, etc.
  final ValidationResourcesBase resources;

  /// Controls case sensitivity behavior during string validation.
  ///
  /// - `CaseHandling.exact` — validation is case-sensitive (e.g. "Hello" ≠ "hello").
  /// - `CaseHandling.ignore` — validation ignores casing (e.g. "Hello" == "hello").
  ///
  /// Default: `CaseHandling.exact`.
  final CaseHandling caseHandling;

  /// If true, validators will reuse resources between validations.
  ///
  /// Use this to optimize performance for repeated validations.
  ///
  /// Default: `false`.
  final bool usePermanentCache;

  /// Whether validation should stop at the first error encountered.
  ///
  /// Default: `false` — all validators will be executed.
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
          intErrors: IntCheckitErrors(),
          doubleErrors: DoubleCheckitErrors(),
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
    bool? usePermanentCache,
    bool? stopOnFirstError,
  }) {
    return ValidationContext(
      errors: errors ?? this.errors,
      warnings: warnings ?? this.warnings,
      resources: resources ?? this.resources,
      caseHandling: caseHandling ?? this.caseHandling,
      usePermanentCache: usePermanentCache ?? this.usePermanentCache,
      stopOnFirstError: stopOnFirstError ?? this.stopOnFirstError,
    );
  }
}
