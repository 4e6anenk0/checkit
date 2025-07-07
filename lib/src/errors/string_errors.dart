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
  hasRepeats();
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
  alpha() => 'The string must contain only alphabetic characters';
  @override
  alphanumeric() => 'The string must contain only alphanumeric characters';
  @override
  contains(String data) => 'The string must contain "$data"';

  @override
  exact(int length) => 'The string must be exactly $length characters long.';

  @override
  equals(String expectedString) =>
      'The string must exactly match "$expectedString".';

  @override
  isDouble() => 'The string must be parsed as double';

  @override
  isInt() => 'The string must be parsed as int';

  @override
  hasSymbols(String symbols) =>
      'String must contain multiple required symbols from the set: "$symbols"';

  @override
  endsWith(String suffix) => 'The string must end with "$suffix".';

  @override
  startsWith(String suffix) => 'The string must start with "$suffix".';

  @override
  jwt() => 'The string is not a valid JSON Web Token (JWT).';

  @override
  hasRepeats() =>
      'Value must contain at least one repeated character in a row (e.g., "bb", "!!", or "22").';
}
