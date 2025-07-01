import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:checkit/checkit.dart';
import 'package:checkit/src/checkit.dart';
import 'package:validart/validart.dart';

final testInputs = List<String>.generate(10000, (i) {
  if (i % 4 == 0) return 'avhsd456#124!';
  if (i % 4 == 1) return '   ';
  if (i % 4 == 2) return '1234';
  return '3243 32434';
});

class CheckitBenchmark extends BenchmarkBase {
  CheckitBenchmark() : super('Checkit');

  final validator =
      Checkit.string
          .password()
          .hasDigit()
          .hasLowercase()
          .hasUppercase()
          .hasSpecial()
          .noSpace()
          .build();

  @override
  void run() {
    for (final input in testInputs) {
      validator.validate(input);
    }
  }
}

class CheckitBenchmarkWithOptimization extends BenchmarkBase {
  CheckitBenchmarkWithOptimization()
    : super('Checkit with optimization (stop on first error)');

  final validator =
      Checkit.string
          .withContext(
            Checkit.config.copyWith(stopOnFirstError: true).buildContext(),
          )
          .password()
          .hasDigit()
          .hasLowercase()
          .hasUppercase()
          .hasSpecial()
          .noSpace()
          .build();

  @override
  void run() {
    for (final input in testInputs) {
      validator.validate(input);
    }
  }
}

class ValidartBenchmark extends BenchmarkBase {
  ValidartBenchmark() : super('Validart');

  final validator = Validart().string().password();

  @override
  void run() {
    for (final input in testInputs) {
      validator.validate(input);
    }
  }
}

void main() {
  print('Running benchmark...\n');

  ValidartBenchmark().report();
  CheckitBenchmark().report();
  CheckitBenchmarkWithOptimization().report();
}
