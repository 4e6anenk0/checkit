import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:checkit/checkit.dart';
import 'package:checkit/src/checkit.dart';
import 'package:validart/validart.dart';

final testInputs = List<String>.generate(10000, (i) {
  if (i % 4 == 0) return '192.168.1.1';
  if (i % 4 == 1) return '   ';
  if (i % 4 == 2) return '2001:db8::ff00:42:8329';
  return '999.999.999.999';
});

class CheckitBenchmark extends BenchmarkBase {
  CheckitBenchmark() : super('Checkit');

  final validator = Checkit.string.ip().build();

  @override
  void run() {
    for (final input in testInputs) {
      validator.validate(input);
    }
  }
}

class CheckitBenchmarkWithOptimization extends BenchmarkBase {
  CheckitBenchmarkWithOptimization() : super('Checkit');

  final validator =
      Checkit.string
          .ip()
          .withContext(
            Checkit.config.copyWith(usePermanentCache: true).buildContext(),
          )
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

  final validator = Validart().string().ip();

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
