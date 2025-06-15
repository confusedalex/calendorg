import 'package:bloc/bloc.dart';
import 'package:calendorg/event.dart';
import 'package:flutter/widgets.dart';
import 'package:org_parser/org_parser.dart';

part 'event_view_event.dart';
part 'event_view_state.dart';

class EventViewBloc extends Bloc<EventViewEvent, EventViewState> {
  EventViewBloc(Event event, OrgTimestamp timestamp)
      : super(EventViewState.inital(event, timestamp)) {
    on<EventViewEvent>((event, emit) {});
    on<EventViewTitleChangeEvent>(
        (event, emit) => emit(state.copyWith(title: event.title)));
    on<EventViewTitleChangeAllDay>(
      (event, emit) => emit(state.copyWith(allDay: event.allDay)),
    );
  }

  bool get isSavable => state.event.title != state.title;

  OrgSection generateNewSection() => state.event.section.copyWith(
          headline: state.event.section.headline.fromChildren([
        OrgContent([OrgPlainText(state.title)])
      ]));
}
