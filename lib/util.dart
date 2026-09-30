import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:org_parser/org_parser.dart';
import 'package:table_calendar/table_calendar.dart';

import 'l10n/calendorg_localizations.dart';

extension L10n on BuildContext {
  CalendorgLocalizations get l10n => CalendorgLocalizations.of(this);
}

String dayLabel(BuildContext context, DateTime day) {
  final now = DateTime.now();
  if (isSameDay(day, now)) return context.l10n.today;
  if (isSameDay(day, now.add(const Duration(days: 1)))) {
    return context.l10n.tomorrow;
  }
  final format = day.year == now.year
      ? DateFormat.MMMMEEEEd()
      : DateFormat.yMMMMEEEEd();
  return format.format(day);
}

String? validate(
  CalendorgLocalizations l10n,
  String? value,
  String object, {
  Iterable<String>? notIn,
}) {
  if (value == null || value.trim().isEmpty) {
    return l10n.validation_empty(object);
  }
  if (notIn != null && notIn.contains(value)) {
    return l10n.validation_exists(object);
  }

  return null;
}

OrgDate dateTimeToOrgDate(DateTime dateTime) {
  final isoDate = dateTime.toIso8601String().split('T')[0].split('-');
  return (
    year: isoDate[0],
    month: isoDate[1],
    day: isoDate[2],
    dayName: _orgDayNames[dateTime.weekday - 1],
  );
}

const _orgDayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

OrgTime dateTimeToOrgTime(DateTime dateTime) {
  final isoTime = dateTime.toIso8601String().split('T')[1].split(':');
  return (hour: isoTime[0], minute: isoTime[1]);
}

(String, String) prefixAndSuffixFromBool(bool isActive) {
  final prefix = isActive ? '<' : '[';
  final suffix = isActive ? '>' : ']';
  return (prefix, suffix);
}

OrgSimpleTimestamp dateTimeToSimpleTimestamp(
  DateTime dateTime,
  bool includeTime,
  bool isActive, {
  Iterable<OrgTimestampModifier> modifiers = const [],
}) {
  final OrgDate date = dateTimeToOrgDate(dateTime);
  final OrgTime? time = includeTime ? dateTimeToOrgTime(dateTime) : null;
  final (prefix, suffix) = prefixAndSuffixFromBool(isActive);
  return OrgSimpleTimestamp(prefix, date, time, modifiers, suffix);
}

OrgTimestamp dateTimeToTimeRangeTimestamp(
  DateTime startDateTime,
  DateTime endDateTime,
  bool isActive,
  bool includeStartTime,
  bool includeEndTime, {
  Iterable<OrgTimestampModifier> modifiers = const [],
}) {
  if (includeStartTime &&
      includeEndTime &&
      isSameDay(startDateTime, endDateTime)) {
    final OrgDate date = dateTimeToOrgDate(startDateTime);
    final OrgTime timeStart = dateTimeToOrgTime(startDateTime);
    final OrgTime timeEnd = dateTimeToOrgTime(endDateTime);
    final (prefix, suffix) = prefixAndSuffixFromBool(isActive);
    return OrgTimeRangeTimestamp(
      prefix,
      date,
      timeStart,
      timeEnd,
      modifiers,
      suffix,
    );
  } else {
    final OrgSimpleTimestamp start = dateTimeToSimpleTimestamp(
      startDateTime,
      includeStartTime,
      isActive,
      modifiers: modifiers,
    );
    final OrgSimpleTimestamp end = dateTimeToSimpleTimestamp(
      endDateTime,
      includeEndTime,
      isActive,
    );
    return OrgDateRangeTimestamp(start, '--', end);
  }
}

extension GetTimeOfDay on OrgTime {
  TimeOfDay get timeOfDay =>
      TimeOfDay(hour: int.parse(this.hour), minute: int.parse(this.minute));
}

extension StartDateTime on OrgTimestamp {
  DateTime get startDateTime => switch (this) {
    OrgSimpleTimestamp() => (this as OrgSimpleTimestamp).dateTime,
    OrgDateRangeTimestamp() => (this as OrgDateRangeTimestamp).startDateTime,
    OrgTimeRangeTimestamp() => (this as OrgTimeRangeTimestamp).startDateTime,
  };
}
