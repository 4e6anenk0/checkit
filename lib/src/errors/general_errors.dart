abstract class GeneralCheckitErrorsBase<T> {
  const GeneralCheckitErrorsBase();
  notNull();
}

class GeneralCheckitErrors<T> extends GeneralCheckitErrorsBase<T> {
  const GeneralCheckitErrors();

  @override
  notNull() => 'Value must be not null';
}
