abstract class NumCheckitErrorsBase {
  const NumCheckitErrorsBase();
  min(num min);
  max(num max);
  positive();
  negative();
  range(num min, num max, {bool includeMin = true, bool includeMax = true});
  multiple(num factor);
}

class NumCheckitErrors<T extends num> extends NumCheckitErrorsBase {
  const NumCheckitErrors();

  @override
  min(num min) => 'The length of string must be at least $min';
  @override
  max(num max) => 'The length of string must be at least $max';
  @override
  String range(
    num min,
    num max, {
    bool includeMin = true,
    bool includeMax = true,
  }) {
    final leftBracket = includeMin ? '[' : '(';
    final rightBracket = includeMax ? ']' : ')';
    return 'Value must be in the range $leftBracket$min, $max$rightBracket';
  }

  @override
  negative() => 'Value must be negative';

  @override
  positive() => 'Value must be positive';

  @override
  multiple(num factor) => 'Value must be a multiple of $factor';
}
