import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:checkit/src/checkit.dart';
import 'package:validart/validart.dart';

// 📦 Подготовим одинаковый список входных данных
final testInputs = List.generate(10000, (i) => 'user${i}@example.com');

// 📌 Checkit Benchmark
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

// 📌 Validart Benchmark
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

// 📌 Native RegExp Benchmark
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

// 📍 Запуск всех тестов
void main() {
  print('Running benchmark...\n');

  CheckitBenchmark().report();
  ValidartBenchmark().report();
  RegExpBenchmark().report();
}
