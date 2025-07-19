/// checkit_core — Core infrastructure for checkit validation engine.
///
/// This internal layer includes shared logic used by the main checkit API,
/// including context management, error definitions, and advanced validator utilities.
///
/// It is designed to be imported
/// by both the main validation API and any custom extensions.
///
/// Useful when:
/// - You need to create custom validator nodes
/// - You want direct control over context, localization, or validation composition
///
/// Exports:
/// - `ValidationContext`, `ValidationResources`
/// - `CheckitErrors`, `Warnings`
/// - Advanced group validators (`AndValidator`, `OrValidator`, etc.)
library;

export 'src/validation_resources.dart';
export 'src/validation_context.dart';
export 'src/validation_result.dart';
export 'src/errors/errors.dart';
export 'src/errors/warnings.dart';
export 'src/advanced_validators/group_validators.dart';
export 'src/advanced_validators/custom_validator.dart';
