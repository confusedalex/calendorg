import 'package:collection/collection.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:org_parser/org_parser.dart';

import '../day_key.dart';
import '../planning_entry.dart';
import '../timestamp.dart';
import 'org_entry_locator.dart';

part 'org_entry.mapper.dart';

@MappableClass(
  discriminatorKey: 'type',
  includeCustomMappers: [OrgTimestampMapper(), OrgPlanningEntryMapper()],
)
class OrgEntry with OrgEntryMappable {
  final OrgEntryLocator locator;
  final String filePath;
  final String fileHash;
  final String? todoKeyword;
  final bool containsTimestampInHeadline;
  final String title;
  final List<String> tags;
  final List<OrgTimestamp> timestamps;
  final OrgPlanningEntry? scheduled;
  final OrgPlanningEntry? deadline;

  List<OrgTimestamp> get unifiedTimestamps => [
    ...timestamps,
    if (scheduled?.value != null) scheduled!.value as OrgTimestamp,
    if (deadline?.value != null) deadline!.value as OrgTimestamp,
  ];

  OrgEntry({
    required this.locator,
    required this.todoKeyword,
    required this.containsTimestampInHeadline,
    required this.title,
    required this.tags,
    required this.timestamps,
    this.scheduled,
    this.deadline,
    required this.filePath,
    required this.fileHash,
  });
}

enum HabitStatus {
  /// The habit is not due yet.
  early,

  /// The habit is due.
  due,

  /// The last day before the habit is overdue.
  lastDay,

  /// The habit is overdue.
  overdue,
}

/// An entry with the property `STYLE: habit` and a repeating `SCHEDULED`
/// timestamp, as in org-habit. A repeater like `.+2d/4d` means: do it at
/// most every 2 days and at least every 4 days.
@MappableClass(discriminatorValue: 'habit')
class OrgHabit extends OrgEntry with OrgHabitMappable {
  /// The days with a completion, sorted and without duplicates.
  final List<DayKey> completions;

  OrgHabit({
    required super.locator,
    required super.todoKeyword,
    required super.containsTimestampInHeadline,
    required super.title,
    required super.tags,
    required super.timestamps,
    required OrgPlanningEntry super.scheduled,
    super.deadline,
    required super.filePath,
    required super.fileHash,
    required this.completions,
  });

  OrgSimpleTimestamp get schedule => scheduled!.value as OrgSimpleTimestamp;

  OrgTimestampModifier get _repeater =>
      schedule.modifiers.firstWhere((modifier) => modifier.isRepeater);

  /// The day of the next repetition.
  DayKey get nextDay => dayKeyOfOrgDate(schedule.date);

  /// The shortest interval between two completions, in days.
  int get minDays => _toDays(_repeater.value, _repeater.unit);

  /// The longest interval between two completions, in days.
  int get maxDays => switch (_repeater.suffix) {
    (:final value, :final unit, delimiter: _) => _toDays(value, unit),
    null => minDays,
  };

  bool doneOn(DayKey day) => binarySearch(completions, day) >= 0;

  bool isDue(DayKey today) => nextDay <= today && !doneOn(today);

  /// The status on [day], from the last completion before [day]. For days
  /// after the last completion, the `SCHEDULED` timestamp sets the status.
  HabitStatus statusOn(DayKey day) {
    final previous = completions.lastWhereOrNull((done) => done < day);
    // Before the first completion, the history is unknown.
    if (previous == null && completions.isNotEmpty) return HabitStatus.early;

    final due = previous == completions.lastOrNull
        ? nextDay
        : addDays(previous!, minDays);
    final deadline = addDays(due, maxDays - minDays);

    if (day < due) return HabitStatus.early;
    if (day < deadline) return HabitStatus.due;
    if (day == deadline) return HabitStatus.lastDay;
    return HabitStatus.overdue;
  }

  /// The number of completions in a row, where no gap is longer than
  /// [maxDays]. The streak is 0 if the habit is overdue on [today].
  int streak(DayKey today) {
    final done = completions.where((day) => day <= today).toList();
    if (done.isEmpty || daysBetween(done.last, today) > maxDays) return 0;

    var streak = 1;
    for (var i = done.length - 1; i > 0; i--) {
      if (daysBetween(done[i - 1], done[i]) > maxDays) break;
      streak++;
    }
    return streak;
  }

  static int _toDays(String value, String unit) =>
      (int.tryParse(value) ?? 1) *
      switch (unit) {
        'w' => 7,
        'm' => 30,
        'y' => 365,
        _ => 1,
      };
}
