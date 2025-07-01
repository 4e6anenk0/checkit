abstract class IntCheckitErrorsBase {
  const IntCheckitErrorsBase();
  divisibleBy(int divisor);
  even();
  odd();
  prime();
  oneOf(Set<int> allowedValues);
  digitCount(int count);
  range(int min, int max, {bool includeMin = true, bool includeMax = true});
  step(int step);
}

class IntCheckitErrors<T extends num> extends IntCheckitErrorsBase {
  const IntCheckitErrors();

  @override
  divisibleBy(int divisor) => 'Value must be divisible by $divisor';

  @override
  even() => 'Value must be even';

  @override
  odd() => 'The number must be odd';

  @override
  String prime() => 'Value must be a prime number';

  @override
  String oneOf(Set<int> allowedValues) =>
      'Value must be one of the following: ${allowedValues.join(", ")}';

  @override
  String digitCount(int count) => 'Value must contain exactly $count digits';

  @override
  String range(
    int min,
    int max, {
    bool includeMin = true,
    bool includeMax = true,
  }) {
    final leftBracket = includeMin ? '[' : '(';
    final rightBracket = includeMax ? ']' : ')';
    return 'Value must be in the range $leftBracket$min, $max$rightBracket';
  }

  @override
  String step(int step) =>
      'Value must increase in steps of $step from the minimum value';
}
