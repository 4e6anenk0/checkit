import 'general_errors.dart';
import 'ip_errors.dart';
import 'num_errors.dart';
import 'password_errors.dart';
import 'string_date_errors.dart';
import 'string_errors.dart';

class CheckitErrorsBase {
  const CheckitErrorsBase({
    required this.stringErrors,
    required this.numErrors,
    required this.generalErrors,
    required this.stringDateErrors,
    required this.passwordErrors,
    required this.ipErrors,
    required this.locale,
  });
  final String locale;
  final StringCheckitErrorsBase stringErrors;
  final NumCheckitErrorsBase numErrors;
  final GeneralCheckitErrorsBase generalErrors;
  final StringDateCheckitErrorsBase stringDateErrors;
  final PasswordCheckitErrorsBase passwordErrors;
  final IpCheckitErrorsBase ipErrors;
}

class LocaleGroup {
  LocaleGroup();

  final Map<String, CheckitErrorsBase> _locales = {};
  final CheckitErrorsBase _en = const CheckitErrorsBase(
    stringErrors: StringCheckitErrors(),
    numErrors: NumCheckitErrors(),
    generalErrors: GeneralCheckitErrors(),
    stringDateErrors: StringDateCheckitErrors(),
    passwordErrors: PasswordCheckitErrors(),
    ipErrors: IpCheckitErrors(),
    locale: 'en',
  );
  String _defaultLocale = 'en';

  String get defaultLocaleKey => _defaultLocale;

  bool changeLocale(String locale) {
    if (_locales.containsKey(locale)) {
      _defaultLocale = locale;
      return true;
    }
    return false;
  }

  void addLocale(CheckitErrorsBase locale) {
    _locales[locale.locale] = locale;
  }

  CheckitErrorsBase getLocale(String locale) {
    final errorsLocale = _locales[locale];
    if (errorsLocale != null) {
      return errorsLocale;
    } else {
      return _en;
    }
  }

  CheckitErrorsBase getDefault() {
    if (_defaultLocale == 'en') return _en;
    final errorsLocale = _locales[_defaultLocale];
    if (errorsLocale != null) {
      return errorsLocale;
    } else {
      return _en;
    }
  }

  CheckitErrorsBase getEnglish() {
    return _en;
  }
}
