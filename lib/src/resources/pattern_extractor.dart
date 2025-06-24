class DatePatternExtractor {
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
    'a': r'(AM|PM)',
  };

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
        return extractTimePartFormats(cleanedInput);
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
      return extractTimePartFormats(datePart!);
    }

    final timeFormats =
        timePart != null ? extractTimePartFormats(timePart) : [];

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

  static List<String> extractTimePartFormats(String input) {
    print(input);
    final cleaned = input.trim();

    print(cleaned);

    final formats = <String>[];

    // Проверяем наличие AM или PM без учёта регистра
    final hasAmPm = RegExp(
      r'\s?(am|pm)',
      caseSensitive: false,
    ).hasMatch(cleaned);

    print(hasAmPm);

    // Удаляем AM/PM (без учёта регистра)
    final cleanedTime =
        cleaned
            .replaceAll(RegExp(r'\s?(am|pm)', caseSensitive: false), '')
            .trim();

    print(cleanedTime);

    final parts = cleanedTime.split(':');
    print(parts.length);
    if (parts.length == 2) {
      formats.add(hasAmPm ? 'hh:mm a' : 'HH:mm');
    } else if (parts.length == 3) {
      formats.add(hasAmPm ? 'hh:mm:ss a' : 'HH:mm:ss');
    }

    print(formats);

    return formats;
  }

  static String _defineSeparator(String input) {
    if (input.contains('-')) return '-';
    if (input.contains('/')) return '/';
    if (input.contains('.')) return '.';
    return '';
  }
}
