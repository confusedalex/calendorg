import 'package:org_parser/org_parser.dart';

/// A day as an int of the form `yyyymmdd`.
typedef DayKey = int;

DayKey dayKeyOf(DateTime date) =>
    date.year * 10000 + date.month * 100 + date.day;

DayKey dayKeyOfOrgDate(OrgDate date) =>
    int.parse(date.year) * 10000 +
    int.parse(date.month) * 100 +
    int.parse(date.day);

DateTime dateOfDayKey(DayKey key) =>
    DateTime(key ~/ 10000, key ~/ 100 % 100, key % 100);

DayKey addDays(DayKey key, int days) {
  final date = dateOfDayKey(key);
  return dayKeyOf(DateTime(date.year, date.month, date.day + days));
}

/// The number of days from [from] to [to]. It is negative if [to] is before
/// [from].
int daysBetween(DayKey from, DayKey to) => DateTime.utc(
  to ~/ 10000,
  to ~/ 100 % 100,
  to % 100,
).difference(DateTime.utc(from ~/ 10000, from ~/ 100 % 100, from % 100)).inDays;
