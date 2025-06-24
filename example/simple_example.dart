import 'package:checkit/checkit.dart';

void main() {
  final validators = [NumValidator.min(10), NumValidator.max(20)];
  final ValidationContext context = ValidationContext.defaultContext();

  final value = -22;
  if (!GeneralValidator.notNull()(value, context).$1) {
    print('Validation Failed');
  } else {
    final results = validators.map((validator) => validator(value, context));
    final combinedResult = results.reduce(
      (a, b) => (a.$1 & b.$1, "${a.$2} ${b.$2 ?? ''}"),
    );

    if (combinedResult.$1) {
      print('Validation Passed');
    } else {
      print('Validation Failed: ${combinedResult.$2}');
    }
  }
}
