import 'package:checkit/checkit.dart';
import 'package:checkit/checkit_core.dart';

void main() {
  final ValidationContext context = ValidationContext.defaultContext();

  final validationNode = NumNode(context);

  final validator = validationNode.max(30).min(10);

  final value = null;

  final result = validator.validateOnce(value);

  result.prettyPrint();
}
