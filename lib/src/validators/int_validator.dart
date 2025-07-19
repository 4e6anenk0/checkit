import 'dart:math';

import 'validator.dart';

abstract class IntValidator {
  static Validator<int> divisibleBy(int divisor, {String? error}) => (
        value,
        context,
      ) {
        if (value % divisor == 0) return (true, null);
        return (false, error ?? context.errors.intErrors.divisibleBy(divisor));
      };

  static Validator<int> even({String? error}) => (value, context) {
        if (value % 2 == 0) return (true, null);
        return (false, error ?? context.errors.intErrors.even());
      };

  static Validator<int> odd({String? error}) => (value, context) {
        if (value % 2 != 0) return (true, null);
        return (false, error ?? context.errors.intErrors.odd());
      };

  static Validator<int> prime({String? error}) => (value, context) {
        if (value < 2) {
          return (false, error ?? context.errors.intErrors.prime());
        }
        if (value == 2) {
          return (true, null);
        }
        if (value % 2 == 0) {
          return (false, error ?? context.errors.intErrors.prime());
        }
        for (int i = 3; i <= sqrt(value.toDouble()).floor(); i += 2) {
          if (value % i == 0) {
            return (false, error ?? context.errors.intErrors.prime());
          }
        }
        return (true, null);
      };

  static Validator<int> oneOf(Set<int> allowedValues, {String? error}) => (
        value,
        context,
      ) {
        if (allowedValues.contains(value)) return (true, null);
        return (false, error ?? context.errors.intErrors.oneOf(allowedValues));
      };

  static Validator<int> digitCount(int count, {String? error}) => (
        value,
        context,
      ) {
        final length = value.abs().toString().length;
        if (length == count) return (true, null);
        return (false, error ?? context.errors.intErrors.digitCount(count));
      };

  static Validator<int> rangeWithStep(
    int min,
    int max,
    int step, {
    String? error,
    bool includeMin = true,
    bool includeMax = true,
  }) =>
      (value, context) {
        if (step <= 0) {
          return (false, 'Step must be positive');
        }

        final minOk = includeMin ? value >= min : value > min;
        final maxOk = includeMax ? value <= max : value < max;

        if (!minOk || !maxOk) {
          return (false, error ?? context.errors.intErrors.range(min, max));
        }

        if ((value - min) % step != 0) {
          return (false, error ?? context.errors.intErrors.step(step));
        }

        return (true, null);
      };
}
