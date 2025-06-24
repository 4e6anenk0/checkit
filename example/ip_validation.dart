import 'package:checkit/checkit.dart';

void main() {
  final validator = Checkit.string.ip().v6();

  final address = '192.168.1.1';
  final result = validator.validateOnce(address, stopOnFirstError: true);

  result.prettyPrint();
}
