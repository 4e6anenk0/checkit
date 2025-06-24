import 'package:checkit/checkit.dart';

void main() {
  final validator = Checkit.num.positive().range(1, 10).build();

  final value = -13;

  var result = validator.validate(value);

  result.prettyPrint();
}
