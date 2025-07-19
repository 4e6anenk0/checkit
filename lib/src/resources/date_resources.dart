import 'package:checkit/src/resources/string_date_parser.dart';

abstract class DateResource {
  bool hasValidDateRangeParts({
    int? day,
    int? month,
    int? year,
    int? second,
    int? minute,
    int? hour,
  }) {
    if (day == null && month == null && year == null) {
      return false;
    }

    if (year != null && (year < 1)) {
      return false;
    }

    if (month != null && (month < 1 || month > 12)) {
      return false;
    }

    if (day != null) {
      if (day < 1 || day > 31) {
        return false;
      }
    }

    if (hour != null) {
      if (hour < 0 || hour > 23) {
        return false;
      }
    }

    if (minute != null) {
      if (minute < 0 || minute > 59) {
        return false;
      }
    }

    if (second != null) {
      if (second < 0 || second > 59) {
        return false;
      }
    }

    return true;
  }

  bool isValidDayInMonth(int day, int month, int year) {
    try {
      final maxDays = getDaysInMonth(year, month);
      return day >= 1 && day <= maxDays;
    } catch (e) {
      return false;
    }
  }

  bool isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  int getDaysInMonth(int year, int month) {
    if (!hasValidDateRangeParts(month: month, year: year)) {
      throw ArgumentError();
    }

    if (month == 2) {
      final isLeap = isLeapYear(year);
      return isLeap ? 29 : 28;
    }
    const monthsWith30Days = {4, 6, 9, 11};
    return monthsWith30Days.contains(month) ? 30 : 31;
  }

  /// Converts a two-digit year (e.g., 23, 89) to a full four-digit year
  /// (e.g., 2023, 1989), making an intelligent guess based on the current year
  /// and a configurable window for future dates.
  ///
  /// ### Args:
  ///   - **[shortYear]**: The two-digit year (0-99).
  ///   - **[currentFullYear]**: Optional. The full year to use as a reference for determining
  ///                             the century. If null, `DateTime.now().year` is used.
  ///   - **[futureWindow]**: Optional. The number of years into the future (from `currentFullYear`)
  ///                       that a `shortYear` can represent in the `currentFullYear`'s century
  ///                       before it's assumed to be from the previous century. Defaults to 20.
  ///
  /// ### Returns:
  ///   int: The calculated four-digit year.
  ///
  /// ### Throws:
  ///   ArgumentError: If `shortYear` is not between 0 and 99.
  ///
  /// ### Example:
  /// ```dart
  ///   // Assuming current year is 2025
  ///   date = DateValidatorUtils();
  ///   print(date.normalizeShortYear(28) == 2028); // true
  ///   print(date.normalizeShortYear(95) == 1995); // true
  /// ```
  int normalizeShortYear(
    int shortYear, {
    int? currentFullYear,
    int futureWindow = 20,
  }) {
    if (shortYear < 0 || shortYear > 99) {
      throw ArgumentError(
        'A two-digit year must be between 0 and 99. Received: $shortYear',
      );
    }

    final int referenceYear = currentFullYear ?? DateTime.now().year;

    final int century = (referenceYear ~/ 100);

    int potentialYear = century * 100 + shortYear;

    // Check if this potentialYear is "too far" into the future
    // compared to the referenceYear plus the allowed futureWindow.
    // If potentialYear = 2095, referenceYear = 2025, futureWindow = 20:
    // 2095 > (2025 + 20) which is 2095 > 2045. This is true.
    // This suggests that '95' more likely refers to 1995 than 2095.
    if (potentialYear > referenceYear + futureWindow) {
      return (century - 1) * 100 + shortYear;
    } else {
      return potentialYear;
    }
  }
}

class DateTimeResource extends DateResource {
  final DateTime _date;

  DateTimeResource(this._date);

  DateTime get date => _date;

  DateTimeResource.fromString(String date, String format)
      : _date = _parseString(date, format);

  static DateTime _parseString(String date, String format) {
    final DateParser parser = DateParser();

    final datetime = parser.tryGetDateTime(date, format);

    if (datetime == null) throw ArgumentError();

    return datetime;
  }

  bool isLeap() {
    return isLeapYear(_date.year);
  }

  bool isInRange(DateTime start, DateTime end, {bool inclusive = false}) {
    if (inclusive) {
      return !_date.isBefore(start) && !_date.isAfter(end);
    }
    return _date.isAfter(start) && _date.isBefore(end);
  }

  bool isNotFuture() {
    final now = DateTime.now();
    return _date.isBefore(now);
  }

  bool isNotPast() {
    final now = DateTime.now();
    return _date.isAfter(now);
  }

  bool isMinYear(int minYear) {
    return _date.year >= minYear;
  }

  bool isMaxYear(int maxYear) {
    return _date.year <= maxYear;
  }

  bool isBefore(DateTime date) {
    return _date.isBefore(date);
  }

  bool isAfter(DateTime date) {
    return _date.isAfter(date);
  }

  isWeekday() {
    return (_date.weekday >= DateTime.monday &&
        _date.weekday <= DateTime.friday);
  }

  isWeekend() {
    return [DateTime.saturday, DateTime.sunday].contains(_date.weekday);
  }
}

class StringDateResource extends DateResource {
  late final DateParser parser;
  final String stringDate;
  final String format;

  StringDateResource(
    this.stringDate,
    this.format, {
    bool normalizeYY = true,
    bool validateDateRanges = true,
    int futureWindow = 20,
    int? currentFullYear,
  }) {
    parser = DateParser(
      normalizeYY: normalizeYY,
      validateDateRanges: validateDateRanges,
      currentFullYear: currentFullYear,
      futureWindow: futureWindow,
    );
  }

  String? convert(String targetFormat) {
    try {
      return parser.convert(stringDate, format, targetFormat);
    } catch (e) {
      return null;
    }
  }

  DateTime? tryGetDateTime() {
    return parser.tryGetDateTime(stringDate, format);
  }

  bool isValidFormat({String? format}) {
    final inputFormat = DateParser.extractDateTimeFormats(stringDate);
    if (inputFormat.isEmpty) return false;

    if (format != null) return inputFormat.contains(format);

    return true;
  }

  bool isValidDate() {
    try {
      final date = parser.parse(stringDate, format);
      return isValidDayInMonth(date.day, date.month, date.year);
    } catch (e) {
      return false;
    }
  }
}
