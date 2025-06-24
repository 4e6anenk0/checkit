import 'package:checkit/checkit.dart';
import 'package:checkit/src/errors/warnings.dart';

void main() {
  final validator =
      Checkit.string.dateTimeAuto().maxYear(2050).minYear(2020).leapYear();

  final value = '2024/09/18';
  final result = validator.validateOnce(value);

  result.prettyPrint();
}
