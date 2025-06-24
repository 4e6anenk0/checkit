import 'package:checkit/checkit.dart';
import 'package:checkit/src/errors/warnings.dart';

void main() {
  final validator = Checkit.string.custom(
    (value, _) => value == value.split('').reversed.join(),
  );

  final palindrome = 'level';
  final result = validator.validateOnce(palindrome);

  result.prettyPrint();
}
