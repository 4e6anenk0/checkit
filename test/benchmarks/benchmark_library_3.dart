import 'dart:io';
import 'dart:isolate';

import 'package:checkit/checkit.dart';
import 'package:validart/validart.dart';

final testInputs = List<String>.generate(10000, (i) {
  if (i % 4 == 0) return 'valid.email$i@example.com';
  if (i % 4 == 1) return '   ';
  if (i % 4 == 2) return 'user%example.com';
  return 'verylongemailstringthatgoesonandonandonandonandonandonandon@example.com';
});

Future<int> measureMemory(void Function() testFn) async {
  final receivePort = ReceivePort();

  await Isolate.spawn((SendPort port) {
    testFn();
    port.send(ProcessInfo.currentRss); // Потребление памяти в байтах
  }, receivePort.sendPort);

  final memoryUsage = await receivePort.first as int;
  return memoryUsage;
}

void validator1() {
  final validator = Checkit.string.email().min(6).max(34).build();
  for (final input in testInputs) {
    validator.validate(input);
  }
}

void validator2() {
  final validator = Validart().string().email().min(6).max(34);
  for (final input in testInputs) {
    validator.validate(input);
  }
}

void main() async {
  final mem1 = await measureMemory(validator1);
  final mem2 = await measureMemory(validator2);

  print('Validator1 использовал ~${mem1 ~/ 1024} KB');
  print('Validator2 использовал ~${mem2 ~/ 1024} KB');
}
