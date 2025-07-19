import 'validator.dart';

abstract class PasswordValidator {
  static Validator<String> typical({String? error}) => (value, context) {
        if (context.resources.typicalPasswordPattern.hasMatch(value)) {
          return (true, null);
        }
        return (false, error ?? context.errors.passwordErrors.typical());
      };

  static Validator<String> strong({String? error}) => (value, context) {
        if (context.resources.strongPasswordPattern.hasMatch(value)) {
          return (true, null);
        }
        return (false, error ?? context.errors.passwordErrors.strong());
      };

  static Validator<String> simple({String? error}) => (value, context) {
        if (context.resources.simplePasswordPattern.hasMatch(value)) {
          return (true, null);
        }
        return (false, error ?? context.errors.passwordErrors.simple());
      };

  static Validator<String> hasUppercase({String? error}) => (value, context) {
        if (context.resources.uppercaseLetterPattern.hasMatch(value)) {
          return (true, null);
        }
        return (false, error ?? context.errors.passwordErrors.hasUppercase());
      };

  static Validator<String> hasLowercase({String? error}) => (value, context) {
        if (context.resources.lowercaseLetterPattern.hasMatch(value)) {
          return (true, null);
        }
        return (false, error ?? context.errors.passwordErrors.hasLowercase());
      };

  static Validator<String> hasDigit({String? error}) => (value, context) {
        if (context.resources.digitPattern.hasMatch(value)) {
          return (true, null);
        }
        return (false, error ?? context.errors.passwordErrors.hasDigit());
      };

  static Validator<String> noSpace({String? error}) => (value, context) {
        if (!context.resources.spacePattern.hasMatch(value)) {
          return (true, null);
        }
        return (false, error ?? context.errors.passwordErrors.noSpace());
      };

  static Validator<String> hasLetter({String? error}) => (value, context) {
        if (context.resources.letterPattern.hasMatch(value)) {
          return (true, null);
        }
        return (false, error ?? context.errors.passwordErrors.hasLetter());
      };

  static Validator<String> hasSpecial({
    String? allowedChars,
    String? error,
  }) =>
      (value, context) {
        String buildSpecialCharPattern(String allowedChars) {
          final escapedChars =
              allowedChars.split('').map(RegExp.escape).toList();

          escapedChars.sort((a, b) {
            if (a == r'-') return 1;
            return -1;
          });

          return '[${escapedChars.join()}]';
        }

        final pattern = allowedChars != null
            ? context.resources.getPatternOrCreate(
                'specialChars',
                buildSpecialCharPattern(allowedChars),
              )
            : context.resources.specialCharsPattern;

        if (pattern.hasMatch(value)) {
          return (true, null);
        }
        return (
          false,
          error ??
              context.errors.passwordErrors.hasSpecial(allowedChars ?? '[\\W]'),
        );
      };

  static Validator<String> noRepeats({String? error}) => (value, context) {
        if (!context.resources.repeatPattern.hasMatch(value)) {
          return (true, null);
        }
        return (false, error ?? context.errors.passwordErrors.noRepeats());
      };
}
