import 'package:checkit/checkit.dart';

void main() {
  final validator = Checkit.string.hasSymbols('a');

  final password = 'Warning!';
  final result = validator.validateOnce(password);

  result.prettyPrint();
}
