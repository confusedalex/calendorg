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
        EventViewSaveEvent() => save(orgFilesBloc),
      },
    );
  }

  void save(OrgFilesBloc bloc) {
    final replacements = <(OrgNode, OrgNode)>[];
    final titleChanged = state.oldEvent.title != state.newEvent.title;
    final timestampChanged = state.oldTimestamp != state.newTimestamp;

    if (state.oldEvent.containsTimestampInHeadline) {
      if (titleChanged || timestampChanged) {
        replacements.add((
          state.oldEvent.section.headline.title as OrgNode,
          OrgContent([OrgPlainText(state.newEvent.title), state.newTimestamp]),
        ));
      }
    } else {
      if (timestampChanged) {
        replacements.add((state.oldTimestamp, state.newTimestamp));
      }
      if (titleChanged) {
        replacements.add((
          state.oldEvent.section.headline.title as OrgNode,
          OrgContent([OrgPlainText(state.newEvent.title)]),
        ));
      }
    }

    bloc.add(OrgFilesReplaceNodes(state.oldEvent.fileInfo, replacements));
  }
}
