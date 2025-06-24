import 'package:checkit/src/resources/string_date_parser.dart';
import 'package:test/test.dart';

void main() {
  group('convert', () {
    final parser = DateParser();
    test('year formats: yyyy and yy', () {
      expect(parser.convert('2024-06-05', 'yyyy-MM-dd', 'yyyy'), '2024');
      expect(parser.convert('2024-06-05', 'yyyy-MM-dd', 'yy'), '24');
    });

    test('month formats: MM and M', () {
      expect(parser.convert('2024-06-05', 'yyyy-MM-dd', 'MM'), '06');
      expect(parser.convert('2024-06-05', 'yyyy-MM-dd', 'M'), '6');
    });

    test('day formats: dd and d', () {
      expect(parser.convert('2024-06-05', 'yyyy-MM-dd', 'dd'), '05');
      expect(parser.convert('2024-06-05', 'yyyy-MM-dd', 'd'), '5');
    });

    test('hour formats: HH and H (24h)', () {
      expect(
        parser.convert('2024-06-05 09:00', 'yyyy-MM-dd HH:mm', 'HH'),
        '09',
      );
      expect(parser.convert('2024-06-05 09:00', 'yyyy-MM-dd HH:mm', 'H'), '9');

      expect(
        parser.convert('2024-06-05 13:00', 'yyyy-MM-dd HH:mm', 'HH'),
        '13',
      );
      expect(parser.convert('2024-06-05 13:00', 'yyyy-MM-dd HH:mm', 'H'), '13');
    });

    test('hour formats: hh and h (12h)', () {
      expect(
        parser.convert('2024-06-05 00:00', 'yyyy-MM-dd HH:mm', 'hh'),
        '12',
      );
      expect(parser.convert('2024-06-05 00:00', 'yyyy-MM-dd HH:mm', 'h'), '12');

      expect(
        parser.convert('2024-06-05 13:00', 'yyyy-MM-dd HH:mm', 'hh'),
        '01',
      );
      expect(parser.convert('2024-06-05 13:00', 'yyyy-MM-dd HH:mm', 'h'), '1');
    });

    test('minute formats: mm and m', () {
      expect(
        parser.convert('2024-06-05 09:05', 'yyyy-MM-dd HH:mm', 'mm'),
        '05',
      );
      expect(parser.convert('2024-06-05 09:05', 'yyyy-MM-dd HH:mm', 'm'), '5');
    });

    test('second formats: ss and s', () {
      expect(
        parser.convert('2024-06-05 09:05:09', 'yyyy-MM-dd HH:mm:ss', 'ss'),
        '09',
      );
      expect(
        parser.convert('2024-06-05 09:05:09', 'yyyy-MM-dd HH:mm:ss', 's'),
        '9',
      );
    });

    test('am/pm format: a', () {
      expect(parser.convert('2024-06-05 09:00', 'yyyy-MM-dd HH:mm', 'a'), 'AM');
      expect(parser.convert('2024-06-05 13:00', 'yyyy-MM-dd HH:mm', 'a'), 'PM');
    });

    test('millisecond: sss', () {
      expect(
        parser.convert(
          '2024-06-05 09:00:12.399',
          'yyyy-MM-dd HH:mm:ss.sss',
          'sss',
        ),
        '399',
      );
      expect(
        parser.convert(
          '2024-06-05 13:00:12.399+02:33',
          'yyyy-MM-dd HH:mm:ss.sssZ',
          'Z',
        ),
        '+02:33',
      );
    });

    test('full date + time', () {
      expect(
        parser.convert(
          '2024-06-05 14:30:09',
          'yyyy-MM-dd HH:mm:ss',
          'yyyy-MM-dd HH:mm:ss',
        ),
        '2024-06-05 14:30:09',
      );
      expect(
        parser.convert(
          '2024-06-05 14:30:09',
          'yyyy-MM-dd HH:mm:ss',
          'dd/MM/yyyy hh:mm:ss a',
        ),
        '05/06/2024 02:30:09 PM',
      );
    });

    test('edge: midnight (00:00)', () {
      expect(
        parser.convert('2024-06-05 00:00', 'yyyy-MM-dd HH:mm', 'hh a'),
        '12 AM',
      );
    });

    test('short year normalization for < 100', () {
      expect(parser.convert('44-06-05', 'yy-MM-dd', 'yyyy'), '2044');
      expect(parser.convert('99-06-05', 'yy-MM-dd', 'yyyy'), '1999');
    });

    test('date without time', () {
      expect(
        parser.convert('2024-06-05', 'yyyy-MM-dd', 'dd-MM-yyyy'),
        '05-06-2024',
      );
    });

    test('time without date', () {
      expect(parser.convert('14:20', 'HH:mm', 'HH:mm'), '14:20');
    });
  });
}
