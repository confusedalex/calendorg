part of 'date_picker_bloc.dart';

final class DatePickerState {
  DatePickerState(
      {required this.startDate,
      required this.startTimeActive,
      startTimeDuration,
      required this.endTimeActive,
      endTimeDuration,
      required this.endDateActive,
      this.endDate})
      : startTimeDuration =
            startTimeDuration ?? TimeOfDay(hour: 12, minute: 00),
        endTimeDuration = endTimeDuration ?? TimeOfDay(hour: 12, minute: 00);

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
                    minute: int.parse(timestamp.time!.minute)));
      case OrgDateRangeTimestamp():
        return DatePickerState(
            startDate: timestamp.start.dateTime,
            startTimeActive: timestamp.start.time != null,
            endTimeActive: timestamp.end.time != null,
            endDateActive: true,
            endDate: timestamp.end.dateTime,
            startTimeDuration: timestamp.start.time?.timeOfDay,
            endTimeDuration: timestamp.end.time?.timeOfDay);
      case OrgTimeRangeTimestamp():
        return DatePickerState(
            startDate: timestamp.startDateTime,
            startTimeActive: true,
            endTimeActive: true,
            endDateActive: false,
            endDate: null,
            startTimeDuration: timestamp.timeStart.timeOfDay,
            endTimeDuration: timestamp.timeEnd.timeOfDay);
    }
  }

  DatePickerState copyWith(
      {DateTime? startDate,
      DateTime? endDate,
      TimeOfDay? startTimeDuration,
      TimeOfDay? endTimeDuration,
      bool? startTimeActive,
      bool? endTimeActive,
      bool? endDateActive}) {
    return DatePickerState(
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        startTimeDuration: startTimeDuration ?? this.startTimeDuration,
        endTimeDuration: endTimeDuration ?? this.endTimeDuration,
        startTimeActive: startTimeActive ?? this.startTimeActive,
        endTimeActive: endTimeActive ?? this.endTimeActive,
        endDateActive: endDateActive ?? this.endDateActive);
  }
}
