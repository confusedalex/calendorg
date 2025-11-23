import 'package:bloc/bloc.dart';
import 'package:calendorg/event.dart';
import 'package:flutter/widgets.dart';
import 'package:org_parser/org_parser.dart';

part 'event_view_event.dart';
part 'event_view_state.dart';

class EventViewBloc extends Bloc<EventViewEvent, EventViewState> {
  late final OrgSection oldSection;
  EventViewBloc(Event event, OrgTimestamp timestamp)
    : super(EventViewState.inital(event, timestamp)) {
    oldSection = event.section;
    on<EventViewEvent>(
      (event, emit) => switch (event) {
        EventViewTitleChangeEvent() => emit(
          state.copyWith(
            title: event.title,
            event: state.event.copyWith(
              section: state.event.section.copyWith(
                headline: state.event.section.headline.fromChildren([
                  OrgContent([
                    OrgPlainText(
                      event.title +
                          (state.event.containsTimestampInHeadline
                              ? " ${state.timestamp.toMarkup()}"
                              : '') +
                          (state.event.tags.isNotEmpty ? ' ' : ''),
                    ),
                  ]),
                ]),
              ),
            ),
          ),
        ),
        EventViewChangeTimestamp() => emit(
          state.copyWith(
            timestamp: event.timestmap,
            event: state.event.copyWith(
              section:
                  state.event.section
                          .edit()
                          .find(state.timestamp)!
                          .replace(event.timestmap)
                          .commit()
                      as OrgSection,
            ),
          ),
        ),
      },
    );
  }
}
