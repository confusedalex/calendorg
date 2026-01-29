part of 'event_view_bloc.dart';

class EventViewState {
  EventViewState({
    required this.oldEvent,
    required this.newEvent,
    required this.oldTimestamp,
    required this.newTimestamp,
  });

  final Event oldEvent;
  final Event newEvent;
  final OrgTimestamp oldTimestamp;
  final OrgTimestamp newTimestamp;

  factory EventViewState.inital(Event event, OrgTimestamp timestamp) =>
      EventViewState(
        oldEvent: event,
        newEvent: event,
        oldTimestamp: timestamp,
        newTimestamp: timestamp,
      );

  EventViewState copyWith({
    Event? oldEvent,
    Event? newEvent,
    OrgTimestamp? oldTimestamp,
    OrgTimestamp? newTimestamp,
  }) {
    return EventViewState(
      oldEvent: oldEvent ?? this.oldEvent,
      newEvent: newEvent ?? this.newEvent,
      oldTimestamp: oldTimestamp ?? this.oldTimestamp,
      newTimestamp: newTimestamp ?? this.newTimestamp,
    );
  }
}
