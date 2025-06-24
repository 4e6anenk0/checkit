import 'package:checkit/src/resources/pattern_extractor.dart';
import 'package:checkit/src/resources/string_date_parser.dart';
import 'package:test/test.dart';

void main() {
  group('DatePatternExtractor.extractDateFormats', () {
    final testCases = <String, List<String>>{
      '2025-06-09T12:34:56.789+02:00': ['yyyy-MM-ddTHH:mm:ss.sssZ'],
      '2025-06-09 12:34:56.789Z': ['yyyy-MM-dd HH:mm:ss.sssZ'],
      '2025-06-09 12:34:56.789-02:00': ['yyyy-MM-dd HH:mm:ss.sssZ'],
      '2025-06-09T12:34:56.789+02:22': ['yyyy-MM-ddTHH:mm:ss.sssZ'],
      '2024-06-05': ['yyyy-MM-dd', 'yyyy-dd-MM'],
      '06/05/2024': ['MM/dd/yyyy'],
      '05.06.2024': ['dd.MM.yyyy'],
      '24-06-05': ['yy-MM-dd'],
      '06/24/05': ['MM/dd/yy'],
      '05.06.24': ['dd.MM.yy'],
      '2024-06-05 14:33': ['yyyy-MM-dd HH:mm'],
      '05/06/2024 01:02': ['dd/MM/yyyy HH:mm'],
      '24-06-05 23:59:59': ['yy-MM-dd HH:mm:ss'],
      '2024-06-05 02:33 PM': ['yyyy-MM-dd hh:mm a'],
      '05.06.2024 11:22:33 PM': ['dd.MM.yyyy hh:mm:ss a'],
      '14:33': ['HH:mm'],
      '23:59:59': ['HH:mm:ss'],
      '02:15 PM': ['hh:mm a'],
      '02:15:45 AM': ['hh:mm:ss a'],
    };

    testCases.forEach((input, expected) {
      test('parses "$input"', () {
        expect(
          DateParser.extractDateTimeFormats(input, allowShortYear: true),
          containsAll(expected),
        );
      });
    });

    test('returns empty for invalid date', () {
      final result = DateParser.extractDateTimeFormats(
        'foo/bar/baz',
        allowShortYear: true,
      );
      print("Вывод: $result");
      expect(result, isEmpty);
    });

    test('returns empty for invalid structure', () {
      final result = DateParser.extractDateTimeFormats(
        '2024',
        allowShortYear: true,
      );
      expect(result, isEmpty);
    });

    test('handles null and empty strings', () {
      expect(
        DateParser.extractDateTimeFormats('', allowShortYear: true),
        isEmpty,
      );
      expect(
        DateParser.extractDateTimeFormats('', allowShortYear: true),
        isEmpty,
      );
      expect(
        DateParser.extractDateTimeFormats('   ', allowShortYear: true),
        isEmpty,
      );
    });
  });
}
