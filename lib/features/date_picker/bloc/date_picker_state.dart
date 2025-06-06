part of 'date_picker_bloc.dart';

final class DatePickerState {
  DatePickerState(
      {required this.startDate,
      required this.startTimeActive,
      this.startTimeDuration,
      required this.endTimeActive,
      this.endTimeDuration,
      required this.endDateActive,
      this.endDate});

  DateTime startDate;
  DateTime? endDate;
  bool startTimeActive;
  Duration? startTimeDuration;
  bool endTimeActive;
  Duration? endTimeDuration;
  bool endDateActive;

  factory DatePickerState.initial(OrgTimestamp timestamp) {
    switch (timestamp) {
      case OrgSimpleTimestamp():
        return DatePickerState(
            startDate: timestamp.dateTime,
            startTimeActive: timestamp.time != null,
            endTimeActive: false,
            endDateActive: false);
      case OrgDateRangeTimestamp():
        return DatePickerState(
            startDate: timestamp.start.dateTime,
            startTimeActive: timestamp.start.time != null,
            endTimeActive: timestamp.end.time != null,
            endDateActive: true,
            endDate: timestamp.end.dateTime);
      case OrgTimeRangeTimestamp():
        return DatePickerState(
            startDate: timestamp.startDateTime,
            startTimeActive: true,
            endTimeActive: true,
            endDateActive: false,
            endDate: timestamp.endDateTime);
    }
  }

  DatePickerState copyWith(
      {DateTime? startDate,
      DateTime? endDate,
      Duration? startTimeDuration,
      Duration? endTimeDuration,
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
