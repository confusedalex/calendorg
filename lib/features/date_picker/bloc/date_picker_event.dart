part of 'date_picker_bloc.dart';

@immutable
sealed class DatePickerEvent {}

final class DatePickerStartDateChanged extends DatePickerEvent {
  final DateTime startDate;
  DatePickerStartDateChanged(this.startDate);
}

final class DatePickerStartTimeActiveChanged extends DatePickerEvent {
  final bool startTimeActive;
  DatePickerStartTimeActiveChanged(this.startTimeActive);
}

final class DatePickerEndTimeActiveChanged extends DatePickerEvent {
  final bool endTimeActive;
  DatePickerEndTimeActiveChanged(this.endTimeActive);
}

final class DatePickerEndDateActiveChanged extends DatePickerEvent {
  final bool endDateActive;
  DatePickerEndDateActiveChanged(this.endDateActive);
}

final class DatePickerEndDateChanged extends DatePickerEvent {
  final DateTime endDate;
  DatePickerEndDateChanged(this.endDate);
}

final class DatePickerStartDurationChanged extends DatePickerEvent {
  final Duration startTimeDuration;
  DatePickerStartDurationChanged(this.startTimeDuration);
}

final class DatePickerEndDurationChanged extends DatePickerEvent {
  final Duration endTimeDuration;
  DatePickerEndDurationChanged(this.endTimeDuration);
}
