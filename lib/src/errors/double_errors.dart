abstract class DoubleCheckitErrorsBase {
  const DoubleCheckitErrorsBase();
  decimal();
  finite();
  integer();
}

class DoubleCheckitErrors<T extends num> extends DoubleCheckitErrorsBase {
  const DoubleCheckitErrors();

  @override
  decimal() => 'The number must be a decimal';

  @override
  finite() => 'The number must be finite';

  @override
  integer() => 'The number must be an integer';
}
