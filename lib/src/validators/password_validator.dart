import 'validator.dart';

abstract class PasswordValidator {
  static Validator<String> hasUppercase({String? error}) => (value, context) {
    if (context.resources.patterns.uppercaseLetterPattern.hasMatch(value)) {
      return (true, null);
    }
    return (false, error ?? context.errors.passwordErrors.hasUppercase());
  };

  static Validator<String> hasLowercase({String? error}) => (value, context) {
    if (context.resources.patterns.lowercaseLetterPattern.hasMatch(value)) {
      return (true, null);
    }
    return (false, error ?? context.errors.passwordErrors.hasLowercase());
  };

  static Validator<String> hasDigit({String? error}) => (value, context) {
    if (context.resources.patterns.digitPattern.hasMatch(value)) {
      return (true, null);
    }
    return (false, error ?? context.errors.passwordErrors.hasDigit());
  };

  static Validator<String> noSpace({String? error}) => (value, context) {
    if (!context.resources.patterns.spacePattern.hasMatch(value)) {
      return (true, null);
    }
    return (false, error ?? context.errors.passwordErrors.noSpace());
  };

  static Validator<String> hasLetter({String? error}) => (value, context) {
    if (context.resources.patterns.letterPattern.hasMatch(value)) {
      return (true, null);
    }
    return (false, error ?? context.errors.passwordErrors.hasLetter());
  };

  static Validator<String> hasSpecial({
    String? allowedChars,
    String? error,
  }) => (value, context) {
    String buildSpecialCharPattern(String allowedChars) {
      final escapedChars = allowedChars.split('').map(RegExp.escape).toList();

      escapedChars.sort((a, b) {
        if (a == r'-') return 1;
        return -1;
      });

      return '[${escapedChars.join()}]';
    }

    final pattern =
        allowedChars != null
            ? context.resources.getPatternOrCreate(
              'specialChars',
              buildSpecialCharPattern(allowedChars),
            )
            : context.resources.patterns.specialCharsPattern;

    if (pattern.hasMatch(value)) {
      return (true, null);
    }
    return (
      false,
      error ??
          context.errors.passwordErrors.hasSpecial(allowedChars ?? '[\\W]'),
    );
  };
}
