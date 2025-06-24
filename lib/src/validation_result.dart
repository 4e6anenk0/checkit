class ValidationResult {
  final bool isValid;
  final List<String> errors;

  const ValidationResult._(this.isValid, this.errors);

  factory ValidationResult.success() => const ValidationResult._(true, []);

  factory ValidationResult.failure(List<String> errors) =>
      ValidationResult._(false, errors);

  factory ValidationResult.auto(bool isValid, List<String> errors) {
    if (!isValid && errors.isEmpty) {
      throw ArgumentError('Errors must be provided when isValid is false');
    }
    return isValid
        ? ValidationResult.success()
        : ValidationResult.failure(errors);
  }

  factory ValidationResult.single(String? message) =>
      message == null
          ? ValidationResult.success()
          : ValidationResult.failure([message]);

  ValidationResult operator &(ValidationResult other) =>
      isValid && other.isValid
          ? ValidationResult.success()
          : ValidationResult.failure([...errors, ...other.errors]);

  ValidationResult operator |(ValidationResult other) =>
      isValid || other.isValid
          ? ValidationResult.success()
          : ValidationResult.failure([...errors, ...other.errors]);

  ValidationResult operator ~() =>
      isValid
          ? ValidationResult.failure(['Negation failed'])
          : ValidationResult.success();

  String? toMessageString([String separator = '\n']) =>
      isValid ? null : errors.join(separator);

  @override
  String toString() => isValid ? 'True' : errors.join('.\n');

  void prettyPrint({String prefix = '', bool useColors = true}) {
    final green = useColors ? '\x1B[32m' : '';
    final red = useColors ? '\x1B[31m' : '';
    final reset = useColors ? '\x1B[0m' : '';

    if (isValid) {
      print('$prefix${green}✅ Valid$reset');
    } else {
      print('$prefix${red}❌ Invalid$reset');
      for (var i = 0; i < errors.length; i++) {
        print('$prefix  ${i + 1}. ${errors[i]}');
      }
    }
  }
}
