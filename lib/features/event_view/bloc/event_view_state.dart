part of 'event_view_bloc.dart';

class EventViewState {
  EventViewState(
      {required this.event,
      required this.timestamp,
      required this.title,
      required this.allDay,
      required this.start,
      this.end});
  final Event event;
  final OrgTimestamp timestamp;
  final String title;
  final bool allDay;
  final DateTime start;
  final DateTime? end;

  factory EventViewState.inital(Event event, OrgTimestamp timestamp) =>
      switch (timestamp) {
        OrgSimpleTimestamp() => EventViewState(
            event: event,
            timestamp: timestamp,
            title: event.title,
            allDay: true,
            start: timestamp.dateTime),
        OrgDateRangeTimestamp() => EventViewState(
            event: event,
            timestamp: timestamp,
            title: event.title,
            allDay: false,
            start: timestamp.start.dateTime,
            end: timestamp.end.dateTime),
        OrgTimeRangeTimestamp() => EventViewState(
            event: event,
            timestamp: timestamp,
            title: event.title,
            allDay: false,
            start: timestamp.startDateTime,
            end: timestamp.endDateTime)
      };

  EventViewState copyWith(
      {Event? event,
      OrgTimestamp? timestamp,
      String? title,
      bool? allDay,
      DateTime? start,
      ValueGetter<DateTime?>? end}) {
    return EventViewState(
        event: event ?? this.event,
        timestamp: timestamp ?? this.timestamp,
        title: title ?? this.title,
        allDay: allDay ?? this.allDay,
        start: start ?? this.start,
        end: end != null ? end() : this.end);
  }
}
