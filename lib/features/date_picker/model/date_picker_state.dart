part of 'date_picker_bloc.dart';

enum DatePickerType { start, end }

final class DatePickerState {
  DatePickerState({
    required this.startDate,
    required this.startTimeActive,
    TimeOfDay? startTimeDuration,
    required this.endTimeActive,
    TimeOfDay? endTimeDuration,
    required this.endDateActive,
    this.endDate,
    this.modifiers = const [],
  }) : startTimeDuration =
           startTimeDuration ?? const TimeOfDay(hour: 12, minute: 00),
       endTimeDuration =
           endTimeDuration ?? const TimeOfDay(hour: 12, minute: 00);

  final DateTime startDate;
  final DateTime? endDate;
  final bool startTimeActive;
  final TimeOfDay startTimeDuration;
  final bool endTimeActive;
  final TimeOfDay endTimeDuration;
  final bool endDateActive;

  final List<OrgTimestampModifier> modifiers;

  bool get endTimeBeforeStart {
    final end = endDateActive ? endDate : null;
    final sameDay = end == null || DateUtils.isSameDay(startDate, end);
    return sameDay &&
        startTimeActive &&
        endTimeActive &&
        endTimeDuration.isBefore(startTimeDuration);
  }

  factory DatePickerState.initial(OrgTimestamp timestamp) {
    switch (timestamp) {
      case OrgSimpleTimestamp():
        return DatePickerState(
          startDate: timestamp.dateTime,
          startTimeActive: timestamp.time != null,
          endTimeActive: false,
          endDateActive: false,
          startTimeDuration: timestamp.time == null
              ? null
              : TimeOfDay(
                  hour: int.parse(timestamp.time!.hour),
                  minute: int.parse(timestamp.time!.minute),
                ),
          modifiers: timestamp.modifiers,
        );
      case OrgDateRangeTimestamp():
        return DatePickerState(
          startDate: timestamp.startDateTime,
          startTimeActive: (timestamp.start as OrgSimpleTimestamp).time != null,
          endTimeActive: (timestamp.end as OrgSimpleTimestamp).time != null,
          endDateActive: true,
          endDate: timestamp.endDateTime,
          startTimeDuration:
              (timestamp.start as OrgSimpleTimestamp).time?.timeOfDay,
          endTimeDuration:
              (timestamp.end as OrgSimpleTimestamp).time?.timeOfDay,
          modifiers: (timestamp.start as OrgSimpleTimestamp).modifiers,
        );
      case OrgTimeRangeTimestamp():
        return DatePickerState(
          startDate: timestamp.startDateTime,
          startTimeActive: true,
          endTimeActive: true,
          endDateActive: false,
          startTimeDuration: timestamp.timeStart.timeOfDay,
          endTimeDuration: timestamp.timeEnd.timeOfDay,
          modifiers: timestamp.modifiers,
        );
    }
  }

  factory DatePickerState.parseDateTimeWithoutTime(DateTime dateTime) =>
      DatePickerState(
        startDate: dateTime,
        startTimeActive: false,
        endTimeActive: false,
        endDateActive: false,
      );

  DatePickerState copyWith({
    DateTime? startDate,
    ValueGetter<DateTime?>? endDate,
    bool? startTimeActive,
    TimeOfDay? startTimeDuration,
    bool? endTimeActive,
    TimeOfDay? endTimeDuration,
    bool? endDateActive,
  }) {
    return DatePickerState(
      startDate: startDate ?? this.startDate,
      endDate: endDate != null ? endDate() : this.endDate,
      startTimeActive: startTimeActive ?? this.startTimeActive,
      startTimeDuration: startTimeDuration ?? this.startTimeDuration,
      endTimeActive: endTimeActive ?? this.endTimeActive,
      endTimeDuration: endTimeDuration ?? this.endTimeDuration,
      endDateActive: endDateActive ?? this.endDateActive,
      modifiers: modifiers,
    );
  }
}
