import '../validation_context.dart';

typedef Validator<T> =
    (bool, String?) Function(T value, ValidationContext context);
