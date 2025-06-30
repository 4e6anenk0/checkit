import 'package:checkit/checkit.dart';
import 'package:checkit/checkit_core.dart';

void main() {
  final validator = AndValidator([
    NumValidator.min(10),
    NumValidator.max(20),
    NumValidator.positive(),
  ], ValidationContext.defaultContext());

  final value = -122;
  final result = validator.validate(value);

  if (result.isValid) {
    print('Validation Passed. \nResult: $result');
  } else {
    print('Validation Failed: \n$result');
  }
}
