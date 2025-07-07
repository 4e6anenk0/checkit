import 'package:checkit/checkit.dart';

void main() {
  final value1 = '2012-12-12';
  final value2 = '2012/12/12';
  final value3 = '2012-31-12';

  final validator = Checkit.string.dateTimeAuto().format('yyyy-MM-dd').build();

  print(validator.validate(value1).isValid); // true
  print(validator.validate(value2).isValid); // false
  print(validator.validate(value3).isValid); // false
}
