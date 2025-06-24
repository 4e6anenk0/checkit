import 'package:checkit/checkit.dart';
import 'package:checkit/src/errors/warnings.dart';

void main() {
  final validator = Checkit.string.not(StringValidator.contains('data'));

  final password = 'data1234-fF';
  final result = validator.validateOnce(password);

  result.prettyPrint();
}
