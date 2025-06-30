class Warnings {
  const Warnings();
  String dateTimeResourceNotFound() =>
      '''Warning! DateTimeResource not found.''';

  String stringDateResourceNotFound() =>
      '''Warning! StringDateResource not found.''';

  String cantParseDateTime() =>
      '''Warning! Can not parse string date to DateTime. The validator attempts to transform
the date string into a DateTime object, but this transformation failed.
The date value may not have been parsed correctly. Please check the input.''';

  String resourcesNotFound() => '''Warning! Can not found needed resources''';
}
