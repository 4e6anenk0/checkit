import 'package:checkit/checkit.dart';
import 'package:test/test.dart';

void main() {
  group('convert', () {
    test('Проверка валидации даты типа yyyy-MM-dd', () {
      expect(
        Checkit.string
            .dateTime('yyyy-MM-dd')
            .validateOnce('2012-12-30')
            .isValid,
        true,
      );
      expect(
        Checkit.string
            .dateTime('yyyy-MM-dd')
            .validateOnce('2022-13-30')
            .isValid,
        false,
      );
      expect(
        Checkit.string
            .dateTime('yyyy-MM-dd')
            .validateOnce('2012-12-33')
            .isValid,
        false,
      );
    });

    test('Проверка валидации даты типа yyyy:MM:dd', () {
      expect(
        Checkit.string
            .dateTime('yyyy:MM:dd')
            .validateOnce('2012:12:30')
            .isValid,
        true,
      );
      expect(
        Checkit.string
            .dateTime('yyyy:MM:dd')
            .validateOnce('2022:13:30')
            .isValid,
        false,
      );
      expect(
        Checkit.string
            .dateTime('yyyy:MM:dd')
            .validateOnce('2012:12:33')
            .isValid,
        false,
      );
    });

    test('Проверка валидации даты типа yyyy-MM-ddTHH:mm:ss.sssZ', () {
      expect(
        Checkit.string
            .dateTime('yyyy-MM-ddTHH:mm:ss.sssZ')
            .validateOnce('2012-12-30T12:30:55.123Z')
            .isValid,
        true,
      );
      expect(
        Checkit.string
            .dateTime('yyyy-MM-ddTHH:mm:ss.sssZ')
            .validateOnce('2012-12-30T12:30:55.123+03:00')
            .isValid,
        true,
      );
      expect(
        Checkit.string
            .dateTime('yyyy-MM-ddTHH:mm:ss.sssZ')
            .validateOnce('2012-12-30T12:30:55.123+030:00')
            .isValid,
        false,
      );
    });

    test('Проверка валидации соответствия типа iso8601', () {
      expect(
        Checkit.string
            .dateTime('yyyy-MM-ddTHH:mm:ss.sssZ')
            .iso8601()
            .validateOnce('2012-12-30T12:30:55.123Z')
            .isValid,
        true,
      );
      expect(
        Checkit.string
            .dateTime('yyyy-MM-ddTHH:mm:ss.sssZ')
            .iso8601()
            .validateOnce('2012/12/30T12:30:55.123+03:00')
            .isValid,
        false,
      );
    });

    test('Проверка валидации времени', () {
      expect(
        Checkit.string.dateTime('HH:mm:ss').validateOnce('12:30:55').isValid,
        true,
      );
      expect(
        Checkit.string.dateTime('HH:mm:ss').validateOnce('25:30:55').isValid,
        false,
      );
      expect(
        Checkit.string.dateTime('HH:mm:ss').validateOnce('12:30:66').isValid,
        false,
      );
    });
  });
}
