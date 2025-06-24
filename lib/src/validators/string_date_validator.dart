import 'package:checkit/src/resources/date_resources.dart';
import 'package:checkit/src/resources/string_date_parser.dart';

import 'validator.dart';

abstract class StringDateValidator {
  static Validator<String> dateTime(String format, {String? error}) => (
    value,
    context,
  ) {
    final stringDateResource = context.resources.getOrCreate(
      'stringDateResource',
      () => StringDateResource(value, format),
    );

    if (stringDateResource.isValidDate()) {
      final datetime = stringDateResource.tryGetDateTime();
      if (datetime == null) {
        return (false, context.warnings.cantParseDateTime());
      }
      final datetimeResource = DateTimeResource(datetime);
      context.resources.setIfAbsent('format', format);
      context.resources.setIfAbsent('datetimeResource', datetimeResource);
      return (true, null);
    }
    return (false, error ?? context.errors.stringDateErrors.date(format));
  };

  static Validator<String> dateTimeIso({String? error}) => (value, context) {
    final formats = DateParser.extractDateTimeFormats(value);
    final isoSet = <String>{
      'yyyy-MM-ddTHH:mm:ss.sssZ',
      'yyyy-MM-ddTHH:mm:ssZ',
      'yyyy-MM-ddTHH:mmZ',
      'yyyy-MM-ddTHH:mm:ss.sss',
      'yyyy-MM-ddTHH:mm:ss',
      'yyyy-MM-ddTHH:mm',
      'yyyy-MM-dd',
    };

    final matchingFormat = formats.firstWhere(
      (f) => isoSet.contains(f),
      orElse: () => '',
    );

    if (matchingFormat.isEmpty) {
      return (false, context.errors.stringDateErrors.iso8601());
    }

    final stringDateResource = context.resources.getOrCreate(
      'stringDateResource',
      () => StringDateResource(value, matchingFormat),
    );

    if (stringDateResource.isValidDate()) {
      final datetime = stringDateResource.tryGetDateTime();
      if (datetime == null) {
        return (false, context.warnings.cantParseDateTime());
      }
      final datetimeResource = DateTimeResource(datetime);
      context.resources.setIfAbsent('format', format);
      context.resources.setIfAbsent('datetimeResource', datetimeResource);
      return (true, null);
    }
    return (
      false,
      error ?? context.errors.stringDateErrors.date(matchingFormat),
    );
  };

  static Validator<String> dateTimeAuto({
    String? preferredFormat,
    String? error,
  }) => (value, context) {
    final formats = DateParser.extractDateTimeFormats(value);

    if (formats.isEmpty) {
      return (false, context.errors.stringDateErrors.date('Empty Format!'));
    }

    String format =
        preferredFormat != null && formats.contains(preferredFormat)
            ? preferredFormat
            : formats.first;

    final stringDateResource = context.resources.getOrCreate(
      'stringDateResource',
      () => StringDateResource(value, format),
    );

    if (stringDateResource.isValidDate()) {
      final datetime = stringDateResource.tryGetDateTime();
      if (datetime == null) {
        return (false, context.warnings.cantParseDateTime());
      }
      final datetimeResource = DateTimeResource(datetime);
      context.resources.setIfAbsent('format', format);
      context.resources.setIfAbsent('datetimeResource', datetimeResource);
      return (true, null);
    }
    return (false, error ?? context.errors.stringDateErrors.date(format));
  };

  static Validator<String> format(String format, {String? error}) => (
    value,
    context,
  ) {
    final stringDateResource = context.resources.getOrCreate(
      'stringDateResource',
      () => StringDateResource(value, format),
    );

    if (stringDateResource.isValidFormat(format: format)) {
      context.resources.set('format', format);
      return (true, null);
    }
    return (false, error ?? context.errors.stringDateErrors.format(format));
  };

  static Validator<String> maxYear(int max, {String? error}) => (
    value,
    context,
  ) {
    final DateTimeResource? datetimeResource = context.resources.tryGet(
      'datetimeResource',
    );
    if (datetimeResource == null) {
      return (false, context.warnings.dateTimeResourceNotFound());
    }
    if (datetimeResource.isMaxYear(max)) return (true, null);
    return (false, error ?? context.errors.stringDateErrors.maxYear(max));
  };

  static Validator<String> minYear(int min, {String? error}) => (
    value,
    context,
  ) {
    final DateTimeResource? datetimeResource = context.resources.tryGet(
      'datetimeResource',
    );
    if (datetimeResource == null) {
      return (false, context.warnings.dateTimeResourceNotFound());
    }
    if (datetimeResource.isMinYear(min)) return (true, null);
    return (false, error ?? context.errors.stringDateErrors.minYear(min));
  };

  static Validator<String> notPast({String? error}) => (value, context) {
    final DateTimeResource? datetimeResource = context.resources.tryGet(
      'datetimeResource',
    );
    if (datetimeResource == null) {
      return (false, context.warnings.dateTimeResourceNotFound());
    }
    if (datetimeResource.isNotPast()) return (true, null);
    return (false, error ?? context.errors.stringDateErrors.notPast());
  };

  static Validator<String> notFuture({String? error}) => (value, context) {
    final DateTimeResource? datetimeResource = context.resources.tryGet(
      'datetimeResource',
    );
    if (datetimeResource == null) {
      return (false, context.warnings.dateTimeResourceNotFound());
    }
    if (datetimeResource.isNotFuture()) return (true, null);
    return (false, error ?? context.errors.stringDateErrors.notFuture());
  };

  static Validator<String> range(
    String start,
    String end, {
    bool inclusive = false,
    String? error,
  }) => (value, context) {
    final StringDateResource? stringDate = context.resources.tryGet(
      'stringDateResource',
    );
    final String? format = context.resources.tryGet('format');
    if (stringDate == null || format == null) {
      return (false, context.warnings.resourcesNotFound());
    }
    final startDateTime = stringDate.parser.tryGetDateTime(start, format);
    final endDateTime = stringDate.parser.tryGetDateTime(start, format);

    if (startDateTime == null || endDateTime == null) {
      return (false, context.warnings.resourcesNotFound());
    }

    final DateTimeResource? datetimeResource = context.resources.tryGet(
      'datetimeResource',
    );
    if (datetimeResource == null) {
      return (false, context.warnings.dateTimeResourceNotFound());
    }
    if (datetimeResource.isInRange(
      startDateTime,
      endDateTime,
      inclusive: inclusive,
    )) {
      return (true, null);
    }
    return (false, error ?? context.errors.stringDateErrors.range(start, end));
  };

  static Validator<String> before(String date, {String? error}) => (
    value,
    context,
  ) {
    final StringDateResource? stringDate = context.resources.tryGet(
      'stringDateResource',
    );
    final String? format = context.resources.tryGet('format');
    if (stringDate == null || format == null) {
      return (false, context.warnings.resourcesNotFound());
    }
    final datetime = stringDate.parser.tryGetDateTime(date, format);

    if (datetime == null) {
      return (false, context.warnings.cantParseDateTime());
    }

    final DateTimeResource? datetimeResource = context.resources.tryGet(
      'datetimeResource',
    );
    if (datetimeResource == null) {
      return (false, context.warnings.dateTimeResourceNotFound());
    }
    if (datetimeResource.isBefore(datetime)) return (true, null);
    return (false, error ?? context.errors.stringDateErrors.before(format));
  };

  static Validator<String> after(String date, {String? error}) => (
    value,
    context,
  ) {
    final StringDateResource? stringDate = context.resources.tryGet(
      'stringDateResource',
    );
    final String? format = context.resources.tryGet('format');
    if (stringDate == null || format == null) {
      return (false, context.warnings.resourcesNotFound());
    }
    final datetime = stringDate.parser.tryGetDateTime(date, format);

    if (datetime == null) {
      return (false, context.warnings.cantParseDateTime());
    }

    final DateTimeResource? datetimeResource = context.resources.tryGet(
      'datetimeResource',
    );
    if (datetimeResource == null) {
      return (false, context.warnings.dateTimeResourceNotFound());
    }
    if (datetimeResource.isAfter(datetime)) return (true, null);
    return (false, error ?? context.errors.stringDateErrors.after(format));
  };

  static Validator<String> leapYear({String? error}) => (value, context) {
    final DateTimeResource? datetimeResource = context.resources.tryGet(
      'datetimeResource',
    );
    if (datetimeResource == null) {
      return (false, context.warnings.dateTimeResourceNotFound());
    }
    if (datetimeResource.isLeap()) return (true, null);
    return (
      false,
      error ??
          context.errors.stringDateErrors.leapYear(
            datetimeResource.date.year.toString(),
          ),
    );
  };

  static Validator<String> iso8601({String? error}) => (value, context) {
    final StringDateResource? stringDate = context.resources.tryGet(
      'stringDateResource',
    );

    if (stringDate == null) {
      return (false, context.warnings.resourcesNotFound());
    }
    final formats = DateParser.extractDateTimeFormats(stringDate.stringDate);
    final isoSet = <String>{
      'yyyy-MM-ddTHH:mm:ss.sssZ',
      'yyyy-MM-ddTHH:mm:ssZ',
      'yyyy-MM-ddTHH:mmZ',
      'yyyy-MM-ddTHH:mm:ss.sss',
      'yyyy-MM-ddTHH:mm:ss',
      'yyyy-MM-ddTHH:mm',
      'yyyy-MM-dd',
    };
    final isIso8601 = formats.any((str) => isoSet.contains(str));

    if (isIso8601) return (true, null);
    return (false, error ?? context.errors.stringDateErrors.iso8601());
  };
}
