import 'package:checkit/checkit.dart';
import 'package:checkit/src/resources/pattern_extractor.dart';
import 'package:checkit/src/resources/string_date_parser.dart';
import 'package:checkit/src/resources/date_resources.dart';

void main() {
  //final date = StringDateResource();

  //print(date.extractDateFormats('12-05-1990'));
  // [dd-MM-yyyy, MM-dd-yyyy] — потому что 12 и 05 оба возможны

  //print(date.extractDateFormats('31-01-1990'));
  // [dd-MM-yyyy] — 31 не может быть месяцем

  //print(date.extractDateFormats('31-01-1990-12'));
  // []

  //print(date.extractDateFormats('1-13-1990'));
  // [MM-dd-yyyy] — 13 не может быть днем

  // print(date.extractDateFormats('01/02/90', allowShortYear: true));
  // [dd/MM/yy, MM/dd/yy]

  //print(date.extractDateFormats('01/02/90', allowShortYear: false));
  // []

  //print(date.extractDateFormats('903.01.02'));
  // []

  // test 2

  //print(date.isValidFormat('12-05-1990', format: 'dd-MM-yyyy')); // true
  //print(date.isValidFormat('12-05-1990', format: 'MM-dd-yyyy')); // true
  //print(date.isValidFormat('12-05-90', format: 'dd-MM-yy')); // true
  //print(date.isValidFormat('12.05.1990', format: 'dd-MM-yyyy')); // false
  //print(date.isValidFormat('12.05.1990', format: 'dd.MM.yyyy')); // true
  //print(date.isValidFormat('31-01-1990', format: 'MM-dd-yyyy')); // false
  //print(date.isValidFormat('12/01/1990'));

  // test 3
  //print(date.isValidDate('12-05-1990', format: 'dd-MM-yyyy')); // true
  //print(date.isValidDate('33-05-1990', format: 'dd-MM-yyyy')); // false
  //print(date.isValidDate('23-44-1990', format: 'dd-MM-yyyy')); // false
  //print(date.isValidDate('02-11-1990', format: 'dd.MM.yyyy')); // false
  //print(date.isValidFormat('31.06.2025', format: 'dd.MM.yyyy'));

  // test 4 Difference
  //print(date.isValidFormat("31-02-2023")); // true
  //print(date.isValidDate("31-02-2023", format: "dd-MM-yyyy")); // false

  // test 5
  /* print(date.convert('02.06.25', 'dd.MM.yy', 'yy-MM-dd'));
  print(date.convert('02.06.25', 'dd.MM.yy', 'yyyy-MM-dd'));
  print(date.convert('13.11.98', 'dd.MM.yy', 'dd.MM.yyyy'));
  print(date.convert('13-11-1998', 'dd-MM-yyyy', 'dd/MM/yyyy'));
  print(date.convert('1-1-1998', 'd-M-yyyy', 'dd/MM/yyyy'));
 */

  /* final dateParser = DateParser(pattern: 'd/M/yy');
  print(dateParser.parse('1/2/24')); // 2024-02-01
  print(dateParser.parse('1/2/97')); // 1997-02-01
  final dateParser2 = DateParser(pattern: 'dd-MM-yy');
  //print(dateParser2.parse('-01-70')); // error
  print(dateParser2.parse('02-01-70')); // 1970-01-02
  final dateParser3 = DateParser(pattern: 'HH:mm a dd-MM-yy');
  print(dateParser3.parse('12:15 AM 04-07-23')); // 2023-07-04 00:15
  print(dateParser3.parse('12:15 PM 04-07-23')); // 2023-07-04 12:15

  final dateParser3WithoutValidation = DateParser(pattern: 'HH:mm a dd-MM-yy');
  print(
    dateParser3WithoutValidation.parse('25:15 AM 04-07-23'),
  ); // 2023-07-04 00:15
  print(
    dateParser3WithoutValidation.parse('12:15 PM 33-07-23'),
  ); // 2023-07-04 12:15

  final dateParser3WithValidation = DateParser(
    pattern: 'HH:mm a dd-MM-yy',
    validateDateRanges: true,
  );
  print(
    dateParser3WithValidation.parse('25:15 AM 04-07-23'),
  ); // 2023-07-04 00:15
  print(
    dateParser3WithValidation.parse('12:15 PM 33-07-23'),
  ); // 2023-07-04 12:15 */

  /* final parser12h = DateParser(pattern: 'MM/dd/yyyy hh:mm a');
  final parser24h = DateParser(pattern: 'yyyy-MM-dd HH:mm');

  print(parser12h.parse('06/07/2025 11:45 PM')); // 2025-06-07 23:45:00
  print(parser12h.parse('06/07/2025 12:00 AM')); // 2025-06-07 00:00:00
  print(parser12h.parse('06/07/2025 12:00 PM')); // 2025-06-07 12:00:00
  print(parser24h.parse('2025-06-07 14:30')); // 2025-06-07 14:30:00 */

  /* final input = "2024.06.07 11:33:22";
  final patterns = DatePatternExtractor.extractDateFormats(input);

  print(patterns); // ['yyyy-MM-dd HH:mm', 'yyyy-dd-MM HH:mm'] */

  final timeResult = DatePatternExtractor.extractDateTimeFormats(
    '28.12.2020 15:30:11 PM',
  );
  print(timeResult); // должен быть ['HH:mm']
}
