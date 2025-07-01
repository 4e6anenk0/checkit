import 'package:checkit/checkit.dart';

void main() {
  final validator = Checkit.string.ip().v6();

  final address = '2001:db8::1'; // :: operator once
  final result = validator.validateOnce(address, stopOnFirstError: true);

  result.prettyPrint();

  final validator2 = Checkit.string.ip().localhost();

  final address2 = '127.0.0.1';

  final result2 = validator2.validateOnce(address2, stopOnFirstError: true);

  result2.prettyPrint();

  final validator3 = Checkit.string.ip();

  final address3 = '::1';

  final result3 = validator3.validateOnce(address3, stopOnFirstError: true);

  result3.prettyPrint();
}
