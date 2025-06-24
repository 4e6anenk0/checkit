abstract class NumCheckitErrorsBase {
  const NumCheckitErrorsBase();
  min(int min);
  max(int max);
  positive();
  negative();
  range(int min, int max);
}

class NumCheckitErrors<T extends num> extends NumCheckitErrorsBase {
  const NumCheckitErrors();

  @override
  min(int min) => 'The length of string must be at least $min';
  @override
  max(int max) => 'The length of string must be at least $max';
  @override
  range(int min, int max) =>
      'The length of string must be between $min and $max';

  @override
  negative() => 'Value must be negative';

  @override
  positive() => 'Value must be positive';
}
