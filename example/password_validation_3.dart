import 'package:checkit/checkit.dart';

void main() {
  final validator = Checkit.string
      .password()
      .not(StringValidator.hasSymbols('A'), error: 'Value must not be A')
      .hasSymbols('BCD')
      .not(StringValidator.hasSymbols('F'), error: 'Value must not be F');

  final password = 'ABCDEF';
  final result = validator.validateOnce(password);

  result.prettyPrint();
}
