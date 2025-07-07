abstract class PasswordCheckitErrorsBase {
  const PasswordCheckitErrorsBase();
  hasUppercase();
  hasLowercase();
  hasDigit();
  noSpace();
  hasLetter();
  hasSpecial(String allowedChars);
  hasSymbols(String symbols);
  typical();
  simple();
  strong();
  noRepeats();
}

class PasswordCheckitErrors extends PasswordCheckitErrorsBase {
  const PasswordCheckitErrors();

  @override
  hasDigit() => 'Password must contain at least one digit (0-9).';

  @override
  hasLetter() => 'Password must contain at least one letter.';

  @override
  hasLowercase() => 'Password must contain at least one lowercase letter.';

  @override
  hasUppercase() => 'Password must contain at least one uppercase letter.';

  @override
  noSpace() => 'Password cannot contain spaces.';

  @override
  hasSpecial(String allowedChars) =>
      'Password must contain at least one special character from the allowed set: $allowedChars';

  @override
  hasSymbols(String symbols) =>
      'Password must contain multiple required symbols from the set: $symbols';

  @override
  simple() =>
      'Password must be at least 4 characters long and contain only letters or numbers.';

  @override
  strong() =>
      'Password must be at least 10 characters long, include at least one uppercase letter, one lowercase letter, one number, one special symbol, and must not contain repeating characters in a row.';

  @override
  typical() =>
      'Password must be at least 8 characters long and include at least one uppercase letter, one lowercase letter, one number, and one special symbol.';

  @override
  noRepeats() =>
      'Password must not contain the same character repeated in a row (e.g., "aa", "11", "%%").';
}
