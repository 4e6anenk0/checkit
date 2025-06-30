/// checkit — Powerful and extensible validation framework for Dart.
///
/// This library provides the high-level API for building and running validations
/// using strongly-typed nodes, reusable validators, and human-friendly syntax.
///
/// Typical usage:
/// ```dart
/// final result = Checkit.string.min(3).email().validateOnce("example@example.com");
/// result.prettyPrint();
/// ```
///
/// Exported content includes:
/// - Entry point (`Checkit`)
/// - Typed validation nodes (e.g., `StringNode`, `NumNode`)
/// - Common validators and their DSL
library;

export 'src/checkit.dart'
    show
        Checkit,
        ValidatorConfig,
        StringDateNode,
        StringNode,
        SubnetNode,
        NumNode,
        IpNode,
        PasswordNode;
export 'src/validators/validators.dart';
