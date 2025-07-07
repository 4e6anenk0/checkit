import 'package:checkit/checkit.dart';

void main() {
  final simpleValidator = Checkit.string.password().simple().build();

  final password1 = 'ABC1';
  final result1 = simpleValidator.validate(password1);

  result1.prettyPrint();

  final typicalValidator = Checkit.string.password().typical().build();

  final password2 = 'pass12A&';
  final result2 = typicalValidator.validate(password2);

  result2.prettyPrint();

  final strongValidator = Checkit.string.password().strong().build();

  final password3 = 'pas123ABC&';
  final result3 = strongValidator.validate(password3);

  result3.prettyPrint();
}
