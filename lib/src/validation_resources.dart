import 'dart:collection';

/// Базовый абстрактный класс ресурсов
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
  final HashMap<String, dynamic> _permanent = HashMap();
  final HashMap<String, dynamic> _temporary = HashMap();

  //ValidationPatterns get patterns;

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

/// Реализация по умолчанию с ленивым кешем
class ValidationResources extends ValidationResourcesBase {
  /*  @override
  ValidationPatterns get patterns => ValidationPatterns(); */

  RegExp? _emailPattern;
  RegExp? _alphaPattern;
  RegExp? _alphanumericPattern;
  RegExp? _uppercaseLetterPattern;
  RegExp? _lowercaseLetterPattern;
  RegExp? _letterPattern;
  RegExp? _digitPattern;
  RegExp? _spacePattern;
  RegExp? _specialCharsPattern;
  RegExp? _jwtPattern;

  @override
  RegExp get emailPattern {
    return _emailPattern ??= RegExp(
      r"^(?!.*\.\.)[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
    );
  }

  @override
  RegExp get alphaPattern {
    return _alphaPattern ??= RegExp(r"^[a-zA-Z]+$");
  }

  @override
  RegExp get alphanumericPattern {
    return _alphanumericPattern ??= RegExp(r"^[a-zA-Z0-9]+$");
  }

  @override
  RegExp get uppercaseLetterPattern {
    return _uppercaseLetterPattern ??= RegExp(r"[A-Z]");
  }

  @override
  RegExp get lowercaseLetterPattern {
    return _lowercaseLetterPattern ??= RegExp(r"[a-z]");
  }

  @override
  RegExp get letterPattern {
    return _letterPattern ??= RegExp(r"[A-Za-z]");
  }

  @override
  RegExp get digitPattern {
    return _digitPattern ??= RegExp(r"\d");
  }

  @override
  RegExp get spacePattern {
    return _spacePattern ??= RegExp(r"\s");
  }

  @override
  RegExp get specialCharsPattern {
    return _specialCharsPattern ??= RegExp(r"[\W]");
  }

  @override
  RegExp get jwtPattern {
    return _jwtPattern ??= RegExp(
      r'^[A-Za-z0-9-_]+\.[A-Za-z0-9-_]+\.[A-Za-z0-9-_]+$',
    );
  }
}
