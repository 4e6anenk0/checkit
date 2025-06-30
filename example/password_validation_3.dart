import 'package:checkit/checkit.dart';
import 'package:checkit/checkit_core.dart';

void main() {
  final validator = Checkit.string
      .password()
      .not(StringValidator.hasSymbols('A'), error: 'Value must not be A')
      .hasSymbols('B')
      .hasSymbols('C')
      .hasSymbols('D')
      .not(StringValidator.hasSymbols('F'), error: 'Value must not be F');

  final password = 'ABCDEF';
  final result = validator.validateOnce(password);

  result.prettyPrint();
}
