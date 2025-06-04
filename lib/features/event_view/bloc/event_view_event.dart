part of 'event_view_bloc.dart';

@immutable
sealed class EventViewEvent {}

final class EventViewTitleChangeEvent extends EventViewEvent {
  final String title;
  EventViewTitleChangeEvent(this.title);
}

final class EventViewTitleChangeAllDay extends EventViewEvent {
  final bool allDay;
  EventViewTitleChangeAllDay(this.allDay);
}
