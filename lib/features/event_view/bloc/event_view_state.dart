part of 'event_view_bloc.dart';

class EventViewState {
  EventViewState({
    required this.event,
    required this.timestamp,
    required this.title,
  });
  final Event event;
  final OrgTimestamp timestamp;
  final String title;

  factory EventViewState.inital(Event event, OrgTimestamp timestamp) =>
      switch (timestamp) {
        OrgSimpleTimestamp() => EventViewState(
            event: event,
            timestamp: timestamp,
            title: event.title,
          ),
        OrgDateRangeTimestamp() => EventViewState(
            event: event,
            timestamp: timestamp,
            title: event.title,
          ),
        OrgTimeRangeTimestamp() => EventViewState(
            event: event,
            timestamp: timestamp,
            title: event.title,
          )
      };

  EventViewState copyWith(
      {Event? event,
      OrgTimestamp? timestamp,
      String? title,
      DateTime? start,
      ValueGetter<DateTime?>? end}) {
    return EventViewState(
      event: event ?? this.event,
      timestamp: timestamp ?? this.timestamp,
      title: title ?? this.title,
    );
  }
}
