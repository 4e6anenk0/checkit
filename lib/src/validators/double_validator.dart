import 'validator.dart';

abstract class DoubleValidator {
  static Validator<double> decimal({String? error}) => (value, context) {
        if (value % 1 != 0) return (true, null);
        return (false, error ?? context.errors.doubleErrors.decimal());
      };

  static Validator<double> finite({String? error}) => (value, context) {
        if (!value.isInfinite || !value.isNaN) return (true, null);
        return (false, error ?? context.errors.doubleErrors.finite());
      };

  static Validator<double> integer({String? error}) => (value, context) {
        if (value % 1 == 0) return (true, null);
        return (false, error ?? context.errors.doubleErrors.integer());
      };
}
