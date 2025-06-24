import 'package:checkit/checkit.dart';
import 'package:checkit/src/errors/warnings.dart';

void main() {
  final validator = Checkit.string
      .password()
      .min(4)
      .max(22)
      .hasUppercase()
      .hasLowercase()
      .hasDigit()
      .noSpace()
      .hasSpecial(allowedChars: '@#\$%&*()-_+=!');

  final password = '1234-fF';
  final result = validator.validateOnce(password);

  result.prettyPrint();
}
