import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../entities/org_entry/org_entry.dart';
import '../../entities/todo_states/todo_states_ignored.dart';
import '../tag_colors/tag_color.dart';

class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.startingDay = StartingDayOfWeek.monday,
    this.tagColors = const [],
    this.todoStates = OrgTodoStatesWithIgnored.defaults,
    this.showHabits = true,
  });

  final ThemeMode themeMode;
  final StartingDayOfWeek startingDay;
  final List<TagColor> tagColors;
  final OrgTodoStatesWithIgnored todoStates;

  /// Show the habits tab. The tab shows only if a habit exists.
  final bool showHabits;

  Color tagColorOf(OrgEntry entry) => tagColors
      .firstWhere(
        (tagColor) => entry.tags.contains(tagColor.tag),
        orElse: () => const TagColor('', Colors.blue),
      )
      .color;

  AppSettings copyWith({
    ThemeMode? themeMode,
    StartingDayOfWeek? startingDay,
    List<TagColor>? tagColors,
    OrgTodoStatesWithIgnored? todoStates,
    bool? showHabits,
  }) => AppSettings(
    themeMode: themeMode ?? this.themeMode,
    startingDay: startingDay ?? this.startingDay,
    tagColors: tagColors ?? this.tagColors,
    todoStates: todoStates ?? this.todoStates,
    showHabits: showHabits ?? this.showHabits,
  );
}
