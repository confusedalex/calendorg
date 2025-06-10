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

final class DatePickerTimeChanged extends DatePickerEvent {
  final TimeOfDay timeDuration;
  final String type;
  DatePickerTimeChanged(this.timeDuration, this.type);
}
