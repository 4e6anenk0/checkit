import 'package:checkit/checkit.dart';

void main() {
  final validator = Checkit.string
      .password()
      .min(4)
      .max(22)
      .hasUppercase()
      .hasLowercase()
      .hasDigit()
      .noSpace()
      .hasSpecial()
      .hasSymbols('fF')
      .noRepeats();

  final password = '1234-fF';
  final result = validator.validateOnce(password);

  result.prettyPrint();
}
