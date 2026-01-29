part of 'event_view_bloc.dart';

@immutable
sealed class EventViewEvent {}

final class EventViewTitleChangeEvent extends EventViewEvent {
  final String title;
  EventViewTitleChangeEvent(this.title);
}

final class EventViewChangeTimestamp extends EventViewEvent {
  final OrgTimestamp timestamp;
  EventViewChangeTimestamp(this.timestamp);
}

final class EventViewSaveEvent extends EventViewEvent {
  EventViewSaveEvent();
}
