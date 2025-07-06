abstract class PasswordCheckitErrorsBase {
  const PasswordCheckitErrorsBase();
  hasUppercase();
  hasLowercase();
  hasDigit();
  noSpace();
  hasLetter();
  hasSpecial(String allowedChars);
  hasSymbols(String symbols);
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
}
