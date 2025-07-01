abstract class StringDateCheckitErrorsBase {
  const StringDateCheckitErrorsBase();
  date(String format);
  format(String format);
  maxYear(int year);
  minYear(int year);
  notPast();
  notFuture();
  range(String start, String end);
  before(String date);
  after(String date);
  leapYear(String date);
  weekend();
  weekday();
  iso8601();
}

class StringDateCheckitErrors extends StringDateCheckitErrorsBase {
  const StringDateCheckitErrors();

  @override
  String date(String format) =>
      'Could not recognize date. Expected format: $format.';

  @override
  String format(String format) =>
      'Date does not match the expected format: $format.';

  @override
  String maxYear(int year) => 'Year must not be after $year.';

  @override
  String minYear(int year) => 'Year must not be before $year.';

  @override
  String notPast() => 'Date must not be in the past.';

  @override
  String notFuture() => 'Date must not be in the future.';

  @override
  String range(String start, String end) =>
      'Year must be between $start and $end.';

  @override
  String before(String date) => 'Date must be before $date.';

  @override
  String after(String date) => 'Date must be after $date.';

  @override
  String leapYear(String year) => 'The year $year is not a leap year.';

  @override
  String iso8601() => 'Date must be in ISO 8601 format (e.g., 2023-12-31).';

  @override
  weekday() => 'The date must be a weekday (Monday to Friday)';

  @override
  weekend() => 'The date must be a weekend day (Saturday or Sunday)';
}
