class DateParser {
  final bool normalizeYY;
  final bool validateDateRanges;
  final int? currentFullYear;
  final int futureWindow;

  late RegExp _regex;
  late List<String> _tokenOrder;

  DateParser({
    this.normalizeYY = true,
    this.validateDateRanges = false,
    this.currentFullYear,
    this.futureWindow = 20,
  });

  static const _tokenRegex = {
    'yyyy': r'(\d{4})',
    'yy': r'(\d{2})',
    'MM': r'(\d{2})',
    'M': r'(\d{1,2})',
    'dd': r'(\d{2})',
    'd': r'(\d{1,2})',
    'HH': r'(\d{2})',
    'hh': r'(\d{2})',
    'mm': r'(\d{2})',
    'ss': r'(\d{2})',
    'sss': r'(\d{3})',
    'a': r'(AM|PM)',
    'Z': r'(Z|[+-]\d{2}:\d{2})',
  };

  bool hasValidDateRanges({
    required int day,
    required int month,
    required int year,
    int? second,
    int? minute,
    int? hour,
  }) {
    if (year < 1 && month < 1 || month > 12 && day < 1 || day > 31) {
      return false;
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

  String _createRegexString(String pattern) {
    final keys =
        _tokenRegex.keys.toList()..sort((a, b) => b.length.compareTo(a.length));
    final tokenPattern = RegExp(keys.join('|'));
    final buffer = StringBuffer('^');
    _tokenOrder = [];
    int lastIndex = 0;

    for (final match in tokenPattern.allMatches(pattern)) {
      final token = match.group(0);
      if (token == null) continue;
      _tokenOrder.add(token);

      if (match.start > lastIndex) {
        buffer.write(RegExp.escape(pattern.substring(lastIndex, match.start)));
      }

      buffer.write(_tokenRegex[token]);
      lastIndex = match.end;
    }

    if (lastIndex < pattern.length) {
      buffer.write(RegExp.escape(pattern.substring(lastIndex)));
    }

    buffer.write(r'$');
    //_regex = RegExp(buffer.toString(), caseSensitive: false);
    return buffer.toString();
  }

  DateTimeParts parse(String date, String format) {
    _regex = RegExp(_createRegexString(format), caseSensitive: false);
    final match = _regex.firstMatch(date);
    if (match == null) {
      throw ArgumentError(
        'Failed to parse the date because the provided value did not match the pattern.',
      );
    }

    final values = _extractValues(match);
    return _buildDate(values);
  }

  String convert(String date, String format, String targetFormat) {
    final datetime = parse(date, format);

    print(datetime.toString());

    String year = datetime.year.toString().padLeft(4, '0');
    String shortYear = datetime.year.toString().padLeft(2, '0').substring(2);
    if (datetime.year < 100 && targetFormat.contains(RegExp(r'y{4}'))) {
      year = normalizeShortYear(datetime.year).toString().padLeft(4, '0');
      shortYear = year.substring(2);
    }

    final paddedMonth = datetime.month.toString().padLeft(2, '0');
    final month = datetime.month.toString();

    final paddedDay = datetime.day.toString().padLeft(2, '0');
    final day = datetime.day.toString();

    final hour24 = datetime.hour.toString();
    final paddedHour24 = datetime.hour.toString().padLeft(2, '0');

    final hour12Value = datetime.hour % 12 == 0 ? 12 : datetime.hour % 12;
    final hour12 = hour12Value.toString();
    final paddedHour12 = hour12Value.toString().padLeft(2, '0');

    final minute = datetime.minute.toString();
    final paddedMinute = datetime.minute.toString().padLeft(2, '0');

    final millisecond = datetime.millisecond.toString().padLeft(3, '0');

    final second = datetime.second.toString();
    final paddedSecond = datetime.second.toString().padLeft(2, '0');

    final ampm = datetime.hour >= 12 ? 'PM' : 'AM';

    final tzOffset = datetime.timezoneOffset;

    final tzSuffix = () {
      if (tzOffset == null) return '';
      if (tzOffset.inMinutes == 0) return 'Z';
      final sign = tzOffset.isNegative ? '-' : '+';
      final totalMinutes = tzOffset.abs().inMinutes;
      final hours = (totalMinutes ~/ 60).toString().padLeft(2, '0');
      final minutes = (totalMinutes % 60).toString().padLeft(2, '0');
      return '$sign$hours:$minutes';
    }();

    var result = targetFormat;

    result = result.replaceAllMapped(RegExp(r'y{4}'), (_) => year);
    result = result.replaceAllMapped(RegExp(r'y{2}'), (_) => shortYear);

    result = result.replaceAllMapped(RegExp(r'MM'), (_) => paddedMonth);
    result = result.replaceAllMapped(RegExp(r'\bM\b'), (_) => month);

    result = result.replaceAllMapped(RegExp(r'dd'), (_) => paddedDay);
    result = result.replaceAllMapped(RegExp(r'\bd\b'), (_) => day);

    result = result.replaceAllMapped(RegExp(r'HH'), (_) => paddedHour24);
    result = result.replaceAllMapped(RegExp(r'\bH\b'), (_) => hour24);

    result = result.replaceAllMapped(RegExp(r'hh'), (_) => paddedHour12);
    result = result.replaceAllMapped(RegExp(r'\bh\b'), (_) => hour12);

    result = result.replaceAllMapped(RegExp(r'mm'), (_) => paddedMinute);
    result = result.replaceAllMapped(RegExp(r'\bm\b'), (_) => minute);

    result = result.replaceAllMapped(RegExp(r'sss'), (_) => millisecond);
    result = result.replaceAllMapped(RegExp(r'ss'), (_) => paddedSecond);
    result = result.replaceAllMapped(RegExp(r'\bs\b'), (_) => second);

    result = result.replaceAllMapped(RegExp(r'\ba\b'), (_) => ampm);

    result = result.replaceAllMapped(RegExp(r'Z'), (_) => tzSuffix);

    return result;
  }

  Map<String, String> _extractValues(RegExpMatch match) {
    final values = <String, String>{};

    for (int i = 0; i < _tokenOrder.length; i++) {
      final group = match.group(i + 1);
      if (group == null) {
        throw FormatException('Missing value for token ${_tokenOrder[i]}.');
      }
      values[_tokenOrder[i]] = group;
    }

    return values;
  }

  DateTimeParts _buildDate(Map<String, String> values) {
    int year;

    if (values.containsKey('yyyy')) {
      year = int.parse(values['yyyy']!);
    } else if (values.containsKey('yy')) {
      if (!normalizeYY) {
        throw FormatException('normalizeYY is false — short year not allowed.');
      }
      final shortYear = int.parse(values['yy']!);
      year = normalizeShortYear(shortYear);
    } else {
      //throw FormatException('Year is not provided');
      year = DateTime.now().year;
    }

    final month = int.parse(values['MM'] ?? values['M'] ?? '1');
    final day = int.parse(values['dd'] ?? values['d'] ?? '1');
    final minute = int.parse(values['mm'] ?? '0');
    final second = int.parse(values['ss'] ?? '0');
    final millisecond = int.parse(values['sss'] ?? '0');
    //var hour = int.parse(values['HH'] ?? '0');
    int hour;

    if (values.containsKey('HH')) {
      hour = int.parse(values['HH']!);
    } else if (values.containsKey('hh')) {
      hour = int.parse(values['hh']!);
      final ampm = values['a']?.toUpperCase();
      if (ampm == null) {
        throw FormatException('12-hour format requires AM/PM indicator');
      }
      if (hour < 1 || hour > 12) {
        throw FormatException(
          'Hour must be between 1 and 12 in 12-hour format',
        );
      }
      if (ampm == 'PM' && hour != 12) hour += 12;
      if (ampm == 'AM' && hour == 12) hour = 0;
    } else {
      hour = 0;
    }

    Duration? timezoneOffset;
    if (values.containsKey('Z')) {
      final tz = values['Z']!;
      if (tz == 'Z') {
        timezoneOffset = Duration.zero;
      } else {
        final parts = tz.split(':');
        final sign = tz.startsWith('-') ? -1 : 1;
        final hours = int.parse(parts[0].substring(1)); // Skip ±
        final minutes = int.parse(parts[1]);
        timezoneOffset = Duration(hours: sign * hours, minutes: sign * minutes);
      }
    }

    if (validateDateRanges) {
      if (!hasValidDateRanges(
        day: day,
        month: month,
        year: year,
        hour: hour,
        minute: minute,
        second: second,
      )) {
        throw ArgumentError('The date parts were not validated successfully.');
      }
    }

    //return DateTime(year, month, day, hour, minute, second);
    return DateTimeParts(
      year,
      month,
      day,
      hour: hour,
      minute: minute,
      second: second,
      millisecond: millisecond,
      timezoneOffset: timezoneOffset,
    );
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
        'A two-digit year must be between 0 and 99. Received: $shortYear.',
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

  DateTime? tryGetDateTime(String date, String format) {
    // Change it
    try {
      final parts = parse(date, format);
      return DateTime(
        parts.year,
        parts.month,
        parts.day,
        parts.hour,
        parts.minute,
        parts.second,
      );
    } catch (e) {
      return null;
    }
  }

  static String _defineSeparator(String input) {
    if (input.contains('-')) return '-';
    if (input.contains('/')) return '/';
    if (input.contains('.')) return '.';
    return '';
  }

  static List<String> extractDateTimeFormats(
    String input, {
    bool allowShortYear = false,
  }) {
    final cleanedInput = input.trim();
    if (cleanedInput.isEmpty) return [];

    final separators = [' ', 'T'];
    final separatorRegExp = RegExp(separators.map(RegExp.escape).join('|'));
    final parts = cleanedInput.split(separatorRegExp);

    String? datePart;
    String? timePart;
    String? separator;

    if (parts.length == 2) {
      separator = separatorRegExp.firstMatch(cleanedInput)?.group(0);

      final hasMeridian = cleanedInput.contains(
        RegExp(r'\s?(am|pm)', caseSensitive: false),
      );
      if (separator == null || hasMeridian) {
        return _extractTimePartFormats(cleanedInput);
      } else {
        datePart = parts[0];
        timePart = parts[1];
      }
    } else if (parts.length == 1) {
      datePart = parts[0];
    } else {
      final match = separatorRegExp.firstMatch(cleanedInput);
      if (match != null) {
        separator = match.group(0)!;
        datePart = cleanedInput.substring(0, match.start);
        timePart = cleanedInput.substring(match.end).trim();
      }
    }

    final dateFormats = _extractDatePartFormats(datePart ?? '', allowShortYear);

    if (dateFormats.isEmpty) {
      //Maybe it was a time, for instance: '15:30 AM'.
      return _extractTimePartFormats(datePart!);
    }

    final timeFormats =
        timePart != null ? _extractTimePartFormats(timePart) : [];

    if (timeFormats.isEmpty) return dateFormats;

    return [
      for (final d in dateFormats)
        for (final t in timeFormats) '$d$separator$t',
    ];
  }

  static List<String> _extractDatePartFormats(
    String date,
    bool allowShortYear,
  ) {
    final separator = _defineSeparator(date);
    if (separator.isEmpty) return [];

    final parts = date.split(separator);
    if (parts.length != 3) return [];

    final candidates = <int, List<String>>{};

    for (int i = 0; i < 3; i++) {
      final part = parts[i];
      final value = int.tryParse(part);
      if (value == null) return [];

      final options = <String>[];

      if (part.length == 4 && value >= 1 && value <= 9999) {
        options.add('yyyy');
      }

      if (allowShortYear && part.length == 2 && value >= 0 && value <= 99) {
        options.add('yy');
      }

      if (part.length <= 2) {
        if (value >= 1 && value <= 12) options.add('MM');
        if (value >= 1 && value <= 31) options.add('dd');
      }

      if (options.isEmpty) return [];

      candidates[i] = options;
    }

    final results = <String>{};

    for (final f0 in candidates[0]!) {
      for (final f1 in candidates[1]!) {
        if (f1 == f0) continue;
        for (final f2 in candidates[2]!) {
          if (f2 == f0 || f2 == f1) continue;
          results.add('$f0$separator$f1$separator$f2');
        }
      }
    }

    return results.toList();
  }

  static List<String> _extractTimePartFormats(String input) {
    final cleaned = input.trim();

    final hasAmPm = RegExp(
      r'\s?(am|pm)',
      caseSensitive: false,
    ).hasMatch(cleaned);
    final hasMilliseconds = RegExp(r'\.\d{1,3}').hasMatch(cleaned);
    final hasTimeZone = RegExp(r'(Z|[+-]\d{2}:?\d{2}?)$').hasMatch(cleaned);

    // Удаляем AM/PM, миллисекунды и временную зону для анализа основной структуры
    var cleanedTime =
        cleaned
            .replaceAll(RegExp(r'\s?(am|pm)', caseSensitive: false), '')
            .replaceAll(RegExp(r'\.\d{1,3}'), '')
            .replaceAll(RegExp(r'(Z|[+-]\d{2}:?\d{2}?)$'), '')
            .trim();

    final parts = cleanedTime.split(':');

    final formats = <String>[];

    String base;
    if (parts.length == 2) {
      base = hasAmPm ? 'hh:mm' : 'HH:mm';
    } else if (parts.length == 3) {
      base = hasAmPm ? 'hh:mm:ss' : 'HH:mm:ss';
    } else {
      return formats;
    }

    if (hasMilliseconds) base += '.sss';
    if (hasAmPm) base += ' a';
    if (hasTimeZone) base += 'Z';

    formats.add(base);
    return formats;
  }
}

class DateTimeParts {
  final int year;
  final int month;
  final int day;
  final int hour;
  final int minute;
  final int second;
  final int millisecond;
  final Duration? timezoneOffset;

  DateTimeParts(
    this.year,
    this.month,
    this.day, {
    this.hour = 0,
    this.minute = 0,
    this.second = 0,
    this.millisecond = 0,
    this.timezoneOffset,
  });

  DateTime toDateTime() {
    final dt = DateTime.utc(
      year,
      month,
      day,
      hour,
      minute,
      second,
      millisecond,
    );
    if (timezoneOffset == null) {
      return dt.toLocal(); // або dt
    } else {
      return dt.subtract(timezoneOffset!);
    }
  }

  @override
  String toString() {
    return 'DateParts: year [$year], month [$month], day [$day], minute [$minute], second [$second], millisecond [$millisecond], timezone [$timezoneOffset]';
  }
}
