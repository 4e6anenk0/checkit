import '../resources/date_resources.dart';

import 'validator.dart';

abstract class DateTimeValidator {
  static Validator<DateTime> maxYear(int max, {String? error}) => (
    value,
    context,
  ) {
    final DateTimeResource? datetimeResource = context.resources.getOrCreate(
      value.toString(),
      () => DateTimeResource(value),
    );
    if (datetimeResource == null) {
      return (false, context.warnings.dateTimeResourceNotFound());
    }
    if (datetimeResource.isMaxYear(max)) return (true, null);
    return (false, error ?? context.errors.stringDateErrors.maxYear(max));
  };

  static Validator<DateTime> minYear(int min, {String? error}) => (
    value,
    context,
  ) {
    final DateTimeResource datetimeResource = context.resources.getOrCreate(
      value.toString(),
      () => DateTimeResource(value),
    );

    if (datetimeResource.isMinYear(min)) return (true, null);
    return (false, error ?? context.errors.stringDateErrors.minYear(min));
  };

  static Validator<DateTime> notPast({String? error}) => (value, context) {
    final DateTimeResource datetimeResource = context.resources.getOrCreate(
      value.toString(),
      () => DateTimeResource(value),
    );

    if (datetimeResource.isNotPast()) return (true, null);
    return (false, error ?? context.errors.stringDateErrors.notPast());
  };

  static Validator<DateTime> notFuture({String? error}) => (value, context) {
    final DateTimeResource datetimeResource = context.resources.getOrCreate(
      value.toString(),
      () => DateTimeResource(value),
    );

    if (datetimeResource.isNotFuture()) return (true, null);
    return (false, error ?? context.errors.stringDateErrors.notFuture());
  };

  static Validator<DateTime> range(
    DateTime start,
    DateTime end, {
    bool inclusive = false,
    String? error,
  }) => (value, context) {
    final DateTimeResource datetimeResource = context.resources.getOrCreate(
      value.toString(),
      () => DateTimeResource(value),
    );

    if (datetimeResource.isInRange(start, end, inclusive: inclusive)) {
      return (true, null);
    }
    return (
      false,
      error ??
          context.errors.stringDateErrors.range(
            start.toString(),
            end.toString(),
          ),
    );
  };

  static Validator<DateTime> before(DateTime date, {String? error}) => (
    value,
    context,
  ) {
    final DateTimeResource datetimeResource = context.resources.getOrCreate(
      value.toString(),
      () => DateTimeResource(value),
    );
    if (datetimeResource.isBefore(date)) return (true, null);
    return (
      false,
      error ?? context.errors.stringDateErrors.before(date.toString()),
    );
  };

  static Validator<DateTime> after(DateTime date, {String? error}) => (
    value,
    context,
  ) {
    final DateTimeResource datetimeResource = context.resources.getOrCreate(
      value.toString(),
      () => DateTimeResource(value),
    );
    if (datetimeResource.isAfter(date)) return (true, null);
    return (
      false,
      error ?? context.errors.stringDateErrors.after(date.toString()),
    );
  };

  static Validator<DateTime> leapYear({String? error}) => (value, context) {
    final DateTimeResource datetimeResource = context.resources.getOrCreate(
      value.toString(),
      () => DateTimeResource(value),
    );
    if (datetimeResource.isLeap()) return (true, null);
    return (
      false,
      error ??
          context.errors.stringDateErrors.leapYear(
            datetimeResource.date.year.toString(),
          ),
    );
  };

  static Validator<DateTime> weekend({String? error}) => (value, context) {
    final DateTimeResource datetimeResource = context.resources.getOrCreate(
      value.toString(),
      () => DateTimeResource(value),
    );
    if (datetimeResource.isWeekend()) return (true, null);
    return (false, error ?? context.errors.stringDateErrors.weekend());
  };

  static Validator<DateTime> weekday({String? error}) => (value, context) {
    final DateTimeResource datetimeResource = context.resources.getOrCreate(
      value.toString(),
      () => DateTimeResource(value),
    );
    if (datetimeResource.isWeekday()) return (true, null);
    return (false, error ?? context.errors.stringDateErrors.weekday());
  };
}
