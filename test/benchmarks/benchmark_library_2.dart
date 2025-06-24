import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:checkit/src/checkit.dart';
import 'package:validart/validart.dart';

final testInputs = List<String>.generate(10000, (i) {
  if (i % 4 == 0) return 'valid.email$i@example.com';
  if (i % 4 == 1) return '   ';
  if (i % 4 == 2) return 'user%example.com';
  return 'verylongemailstringthatgoesonandonandonandonandonandonandon@example.com';
});

class CheckitBenchmark extends BenchmarkBase {
  CheckitBenchmark() : super('Checkit');

  final validator = Checkit.string.email().min(6).max(34).build();

  @override
  void run() {
    for (final input in testInputs) {
      validator.validate(input);
    }
  }
}

class ValidartBenchmark extends BenchmarkBase {
  ValidartBenchmark() : super('Validart');

  final validator = Validart().string().email().min(6).max(34);

  @override
  void run() {
    for (final input in testInputs) {
      validator.validate(input);
    }
  }
}

class RegExpBenchmark extends BenchmarkBase {
  RegExpBenchmark() : super('RegExp');

  final regex = RegExp(
    r"^(?!.*\.\.)[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
  );

  @override
  void run() {
    for (final input in testInputs) {
      regex.hasMatch(input);
    }
  }
}

void main() {
  print('Running benchmark...\n');

  ValidartBenchmark().report();
  CheckitBenchmark().report();
  RegExpBenchmark().report();
}
