abstract class StringCheckitErrorsBase {
  const StringCheckitErrorsBase();
  email();
  min(int length);
  max(int length);
  range(int min, int max);
  alpha();
  alphanumeric();
  contains(String data);
  exact(int length);
  isDouble();
  isInt();
  equals(String expectedString);
  hasSymbols(String symbols);
  endsWith(String suffix);
  startsWith(String suffix);
  jwt();
}

class StringCheckitErrors extends StringCheckitErrorsBase {
  const StringCheckitErrors();
  @override
  email() => 'This email is not match the pattern';
  @override
  min(int length) => 'The length of string must be at least $length';
  @override
  max(int length) => 'The length of string must be at least $length';
  @override
  range(int min, int max) =>
      'The length of string must be between $min and $max';
  @override
  alpha() => "The string must contain only alphabetic characters";
  @override
  alphanumeric() => "The string must contain only alphanumeric characters";
  @override
  contains(String data) => "The string must contain $data";

  @override
  exact(int length) => "";

  @override
  equals(String expectedString) => "";

  @override
  isDouble() => "The string must be parsed as double";

  @override
  isInt() => "The string must be parsed as int";

  @override
  hasSymbols(String symbols) => "";

  @override
  endsWith(String suffix) => "";

  @override
  startsWith(String suffix) => "";

  @override
  jwt() => "";
}
