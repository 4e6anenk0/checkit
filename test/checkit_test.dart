import 'package:checkit/checkit.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    setUp(() {
      // Additional setup goes here.
    });

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
  });
}
