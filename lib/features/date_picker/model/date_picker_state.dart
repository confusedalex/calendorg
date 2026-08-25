part of 'date_picker_bloc.dart';

final class DatePickerState {
  DatePickerState({
    required this.startDate,
    required this.startTimeActive,
    startTimeDuration,
    required this.endTimeActive,
    endTimeDuration,
    required this.endDateActive,
    this.endDate,
  }) : startTimeDuration =
           startTimeDuration ?? const TimeOfDay(hour: 12, minute: 00),
       endTimeDuration =
           endTimeDuration ?? const TimeOfDay(hour: 12, minute: 00);

  DateTime startDate;
  DateTime? endDate;
  bool startTimeActive;
  TimeOfDay startTimeDuration;
  bool endTimeActive;
  TimeOfDay endTimeDuration;
  bool endDateActive;

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
        );
      case OrgTimeRangeTimestamp():
        return DatePickerState(
          startDate: timestamp.startDateTime,
          startTimeActive: true,
          endTimeActive: true,
          endDateActive: false,
          startTimeDuration: timestamp.timeStart.timeOfDay,
          endTimeDuration: timestamp.timeEnd.timeOfDay,
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
    DateTime? endDate,
    bool? startTimeActive,
    TimeOfDay? startTimeDuration,
    bool? endTimeActive,
    TimeOfDay? endTimeDuration,
    bool? endDateActive,
  }) {
    return DatePickerState(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      startTimeActive: startTimeActive ?? this.startTimeActive,
      startTimeDuration: startTimeDuration ?? this.startTimeDuration,
      endTimeActive: endTimeActive ?? this.endTimeActive,
      endTimeDuration: endTimeDuration ?? this.endTimeDuration,
      endDateActive: endDateActive ?? this.endDateActive,
    );
  }
}
