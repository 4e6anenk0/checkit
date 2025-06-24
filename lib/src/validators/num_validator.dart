import 'validator.dart';

abstract class NumValidator {
  static Validator<num> min(int min, {String? error}) => (value, context) {
    if (value >= min) return (true, null);
    return (false, error ?? context.errors.numErrors.min(min));
  };

  static Validator<num> max(int max, {String? error}) => (value, context) {
    if (value <= max) return (true, null);
    return (false, error ?? context.errors.numErrors.max(max));
  };

  static Validator<num> positive({String? error}) => (value, context) {
    if (value >= 0) return (true, null);
    return (false, error ?? context.errors.numErrors.positive());
  };

  static Validator<num> negative({String? error}) => (value, context) {
    if (value <= 0) return (true, null);
    return (false, error ?? context.errors.numErrors.negative());
  };

  static Validator<num> range(int min, int max, {String? error}) => (
    value,
    context,
  ) {
    if (value >= min && value <= max) return (true, null);
    return (false, error ?? context.errors.numErrors.range(min, max));
  };
}
