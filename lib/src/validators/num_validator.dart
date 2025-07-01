import 'validator.dart';

abstract class NumValidator {
  static Validator<num> min(num min, {String? error, bool inclusive = true}) =>
      (value, context) {
        if (inclusive ? value >= min : value > min) return (true, null);
        return (false, error ?? context.errors.numErrors.min(min));
      };

  static Validator<num> max(num max, {String? error, bool inclusive = true}) =>
      (value, context) {
        if (inclusive ? value <= max : value < max) return (true, null);
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

  static Validator<num> range(
    num min,
    num max, {
    String? error,
    bool includeMin = true,
    bool includeMax = true,
  }) => (value, context) {
    final minOk = includeMin ? value >= min : value > min;
    final maxOk = includeMax ? value <= max : value < max;
    if (minOk && maxOk) return (true, null);
    return (false, error ?? context.errors.numErrors.range(min, max));
  };

  static Validator<num> multiple(num factor, {String? error}) => (
    value,
    context,
  ) {
    if (value % factor == 0) return (true, null);
    return (false, error ?? context.errors.numErrors.multiple(factor));
  };
}
