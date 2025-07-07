import 'package:checkit/checkit.dart';
import 'package:checkit/checkit_core.dart';

void main() {
  final List<String> commonPasswords = [
    'password',
    '123456',
    'qwerty',
    'admin',
    'user',
  ];

  final strongPasswordValidator = Checkit.string
      .password()
      .withContext(
        ValidationContext.defaultContext().copyWith(
          stopOnFirstError: true,
          caseHandling: CaseHandling.ignore,
        ),
      )
      .not(
        GeneralValidator.any([
          StringValidator.contains('password'),
          StringValidator.contains('123456'),
          StringValidator.contains('qwerty'),
          StringValidator.contains('admin'),
          StringValidator.contains('user'),
        ]),
        error: 'Password must not contain weak elements.',
      )
      .min(12);

  String goodPassword = 'MySuperSafeP@ssw0rd!';
  var passwordResultGood = strongPasswordValidator.validateOnce(goodPassword);
  print('Пароль: "$goodPassword"');
  passwordResultGood.prettyPrint(); // Ожидаем: Успех

  String weakPassword_ContainsCommon =
      'MyP@ssw0rd!password'; // Содержит 'password'
  var passwordResultWeak1 = strongPasswordValidator.validateOnce(
    weakPassword_ContainsCommon,
  );
  print('Пароль: "$weakPassword_ContainsCommon"');
  passwordResultWeak1.prettyPrint(); // Ожидаем: Ошибка (содержит 'password')

  String weakPassword_IsUsername =
      'username123'; // Идентичен имени пользователя (в этом примере)
  var passwordResultWeak2 = strongPasswordValidator.validateOnce(
    weakPassword_IsUsername,
  );
  print('Пароль: "$weakPassword_IsUsername"');
  passwordResultWeak2
      .prettyPrint(); // Ожидаем: Ошибка (идентичен 'username123')

  String weakPassword_TooShort = 'ShortP@1!'; // Слишком короткий
  var passwordResultWeak3 = strongPasswordValidator.validateOnce(
    weakPassword_TooShort,
  );
  print('Пароль: "$weakPassword_TooShort"');
  passwordResultWeak3.prettyPrint(); // Ожидаем: Ошибка (слишком короткий)
}
