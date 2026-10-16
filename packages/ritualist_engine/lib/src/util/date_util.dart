/// Local-date helpers. All keys are local calendar days (`yyyy-MM-dd`) so that
/// streaks and daily goals follow the user's wall clock, matching Duolingo's
/// behavior. Day arithmetic is done with DateTime constructor normalization
/// (`DateTime(y, m, day - 1)`) which is DST-safe.

String dateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

DateTime parseDateKey(String key) {
  final parts = key.split('-');
  if (parts.length != 3) {
    throw FormatException('Bad date key: $key');
  }
  return DateTime(
    int.parse(parts[0]),
    int.parse(parts[1]),
    int.parse(parts[2]),
  );
}

/// Local key of the day before [d].
String previousDateKey(DateTime d) => dateKey(DateTime(d.year, d.month, d.day - 1));

/// Adds [days] to a date-key, returning a new date-key.
String addDaysToKey(String key, int days) {
  final d = parseDateKey(key);
  return dateKey(DateTime(d.year, d.month, d.day + days));
}
