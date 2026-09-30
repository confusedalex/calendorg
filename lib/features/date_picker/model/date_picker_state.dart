part of 'date_picker_cubit.dart';

enum DatePickerType { start, end }

final class DatePickerState {
  DatePickerState({
    required this.startDate,
    required this.startTimeActive,
    TimeOfDay? startTime,
    required this.endTimeActive,
    TimeOfDay? endTime,
    required this.endDateActive,
    this.endDate,
    this.modifiers = const [],
  }) : startTime = startTime ?? const TimeOfDay(hour: 12, minute: 00),
       endTime = endTime ?? const TimeOfDay(hour: 12, minute: 00);

  final DateTime startDate;
  final DateTime? endDate;
  final bool startTimeActive;
  final TimeOfDay startTime;
  final bool endTimeActive;
  final TimeOfDay endTime;
  final bool endDateActive;

  final List<OrgTimestampModifier> modifiers;

  bool get endTimeBeforeStart {
    final end = endDateActive ? endDate : null;
    final sameDay = end == null || DateUtils.isSameDay(startDate, end);
    return sameDay &&
        startTimeActive &&
        endTimeActive &&
        endTime.isBefore(startTime);
  }

  OrgTimestamp get timestamp {
    final start = startTimeActive
        ? DateTime(
            startDate.year,
            startDate.month,
            startDate.day,
            startTime.hour,
            startTime.minute,
          )
        : startDate;
    final end = endDate;

    if (endDateActive && end != null) {
      return dateTimeToTimeRangeTimestamp(
        start,
        endTimeActive
            ? DateTime(
                end.year,
                end.month,
                end.day,
                endTime.hour,
                endTime.minute,
              )
            : end,
        true,
        startTimeActive,
        endTimeActive,
        modifiers: modifiers,
      );
    } else if (startTimeActive && endTimeActive) {
      return dateTimeToTimeRangeTimestamp(
        start,
        start.copyWith(hour: endTime.hour, minute: endTime.minute),
        true,
        true,
        true,
        modifiers: modifiers,
      );
    } else {
      return dateTimeToSimpleTimestamp(
        start,
        startTimeActive,
        true,
        modifiers: modifiers,
      );
    }
  }

  factory DatePickerState.initial(OrgTimestamp timestamp) {
    switch (timestamp) {
      case OrgSimpleTimestamp():
        return DatePickerState(
          startDate: timestamp.dateTime,
          startTimeActive: timestamp.time != null,
          endTimeActive: false,
          endDateActive: false,
          startTime: timestamp.time == null
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
          startTime: (timestamp.start as OrgSimpleTimestamp).time?.timeOfDay,
          endTime: (timestamp.end as OrgSimpleTimestamp).time?.timeOfDay,
          modifiers: (timestamp.start as OrgSimpleTimestamp).modifiers,
        );
      case OrgTimeRangeTimestamp():
        return DatePickerState(
          startDate: timestamp.startDateTime,
          startTimeActive: true,
          endTimeActive: true,
          endDateActive: false,
          startTime: timestamp.timeStart.timeOfDay,
          endTime: timestamp.timeEnd.timeOfDay,
          modifiers: timestamp.modifiers,
        );
    }
  }

  DatePickerState copyWith({
    DateTime? startDate,
    ValueGetter<DateTime?>? endDate,
    bool? startTimeActive,
    TimeOfDay? startTime,
    bool? endTimeActive,
    TimeOfDay? endTime,
    bool? endDateActive,
  }) {
    return DatePickerState(
      startDate: startDate ?? this.startDate,
      endDate: endDate != null ? endDate() : this.endDate,
      startTimeActive: startTimeActive ?? this.startTimeActive,
      startTime: startTime ?? this.startTime,
      endTimeActive: endTimeActive ?? this.endTimeActive,
      endTime: endTime ?? this.endTime,
      endDateActive: endDateActive ?? this.endDateActive,
      modifiers: modifiers,
    );
  }
}
