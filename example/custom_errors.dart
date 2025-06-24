import 'package:checkit/checkit.dart';

void main() {
  // Создание кастомных ошибок с билдером
  final customErrors =
      ErrorsBuilder()
          .forLocale('ru')
          .numMin('Число {value} должно быть >= {min}')
          .numRange('Число {value} должно быть в диапазоне от {min} до {max}')
          .forLocale('es')
          .numMin('El valor {value} debe ser >= {min}')
          .build();

  // Контекст с кастомными ошибками
  final ruContext = ValidationContext(locale: 'ru', errors: customErrors);

  // Валидатор min
  final minValidator = NumValidator.min(10);
  var result = minValidator(5, context: ruContext);
  print(result.toMessageString()); // Вывод: Число 5 должно быть >= 10

  // Валидатор range
  final rangeValidator = NumValidator.range(10, 20);
  result = rangeValidator(5, context: ruContext);
  print(
    result.toMessageString(),
  ); // Вывод: Число 5 должно быть в диапазоне от 10 до 20

  // Использование с кастомным сообщением
  final minWithError = NumValidator.min(10, error: 'Custom error');
  result = minWithError(5);
  print(result.toMessageString()); // Вывод: Custom error

  // Проверка испанской локали
  final esContext = ValidationContext(locale: 'es', errors: customErrors);
  result = minValidator(5, context: esContext);
  print(result.toMessageString()); // Вывод: El valor 5 debe ser >= 10
}
