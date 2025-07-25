import 'dart:collection';

abstract class ValidationResourcesBase {
  RegExp get emailPattern;
  RegExp get alphaPattern;
  RegExp get alphanumericPattern;
  RegExp get uppercaseLetterPattern;
  RegExp get lowercaseLetterPattern;
  RegExp get letterPattern;
  RegExp get digitPattern;
  RegExp get spacePattern;
  RegExp get specialCharsPattern;
  RegExp get jwtPattern;
  RegExp get typicalPasswordPattern;
  RegExp get strongPasswordPattern;
  RegExp get simplePasswordPattern;
  RegExp get repeatPattern;
  final HashMap<String, dynamic> _permanent = HashMap();
  final HashMap<String, dynamic> _temporary = HashMap();

  T getOrCreate<T>(String key, T Function() factory, {bool temp = true}) {
    final target = temp ? _temporary : _permanent;
    if (target.containsKey(key)) {
      return target[key] as T;
    }
    final value = factory();
    target[key] = value;
    return value;
  }

  T? tryGet<T>(String key, {bool temp = true}) {
    final value = temp ? _temporary[key] : _permanent[key];
    return value is T ? value : null;
  }

  void set<T>(String key, T resource, {bool temp = true}) {
    final target = temp ? _temporary : _permanent;
    target[key] = resource;
  }

  bool setIfAbsent<T>(String key, T resource, {bool temp = true}) {
    final target = temp ? _temporary : _permanent;
    if (!target.containsKey(key)) {
      target[key] = resource;
      return true;
    }
    return false;
  }

  bool contains(String key, {bool temp = true}) =>
      temp ? _temporary.containsKey(key) : _permanent.containsKey(key);
  void remove(String key, {bool temp = true}) =>
      temp ? _temporary.remove(key) : _permanent.remove(key);

  void clear({bool temp = true}) =>
      temp ? _temporary.clear() : _permanent.clear();

  RegExp getPatternOrCreate(String key, String pattern) =>
      getOrCreate<RegExp>(key, () => RegExp(pattern));

  Iterable<String> get keys => {..._permanent.keys, ..._temporary.keys};
}

class ValidationResources extends ValidationResourcesBase {
  @override
  late final RegExp emailPattern = RegExp(
    r"^(?!.*\.\.)[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
  );

  @override
  late final RegExp alphaPattern = RegExp(r"^[a-zA-Z]+$");

  @override
  late final RegExp alphanumericPattern = RegExp(r"^[a-zA-Z0-9]+$");

  @override
  late final RegExp uppercaseLetterPattern = RegExp(r"[A-Z]");

  @override
  late final RegExp lowercaseLetterPattern = RegExp(r"[a-z]");

  @override
  late final RegExp letterPattern = RegExp(r"[A-Za-z]");

  @override
  late final RegExp digitPattern = RegExp(r"\d");

  @override
  late final RegExp spacePattern = RegExp(r"\s");

  @override
  late final RegExp specialCharsPattern = RegExp(r"[\W]");

  @override
  late final RegExp jwtPattern = RegExp(
    r'^[A-Za-z0-9-_]+\.[A-Za-z0-9-_]+\.[A-Za-z0-9-_]+$',
  );

  @override
  late final RegExp strongPasswordPattern = RegExp(
    r'^(?!.*(.)\1)(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{10,}$',
  );

  @override
  late final RegExp typicalPasswordPattern = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$',
  );

  @override
  late final RegExp simplePasswordPattern = RegExp(r'^[a-zA-Z0-9]{4,}$');

  @override
  late final RegExp repeatPattern = RegExp(r'(.)\1');
}
