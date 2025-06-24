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
  hasDigit() => "";

  @override
  hasLetter() => "";

  @override
  hasLowercase() => "";

  @override
  hasUppercase() => "";

  @override
  noSpace() => "";

  @override
  hasSpecial(String allowedChars) => "$allowedChars";

  @override
  hasSymbols(String symbols) => "";
}
