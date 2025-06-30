import 'package:checkit/checkit.dart';

void main() {
  final validator = Checkit.string.hasSymbols('a');

  final password = 'War is bad!';
  final result = validator.validateOnce(password);

  result.prettyPrint();
}
