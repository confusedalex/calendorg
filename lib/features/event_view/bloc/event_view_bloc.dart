import 'package:bloc/bloc.dart';
import 'package:calendorg/core/files/bloc/org_files_bloc.dart';
import 'package:calendorg/event.dart';
import 'package:flutter/widgets.dart';
import 'package:org_parser/org_parser.dart';

part 'event_view_event.dart';
part 'event_view_state.dart';

class EventViewBloc extends Bloc<EventViewEvent, EventViewState> {
  EventViewBloc(OrgFilesBloc orgFilesBloc, Event event, OrgTimestamp timestamp)
    : super(EventViewState.inital(event, timestamp)) {
    on<EventViewEvent>(
      (event, emit) => switch (event) {
        EventViewTitleChangeEvent() => emit(
          state.copyWith(newEvent: state.newEvent.copyWith(title: event.title)),
        ),
        EventViewChangeTimestamp() => emit(
          state.copyWith(newTimestamp: event.timestamp),
        ),
        EventViewSaveEvent() => {
          orgFilesBloc.add(
            OrgFilesReplaceNode(
              state.oldEvent.fileInfo,
              state.oldTimestamp,
              state.newTimestamp,
            ),
          ),
        },
      },
    );
  }
}
