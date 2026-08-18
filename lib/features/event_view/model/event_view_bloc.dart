import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:org_parser/org_parser.dart';

import '../../../core/files/cubit/org_files_cubit.dart';
import '../../../entities/org_entry/org_entry.dart';

part 'event_view_event.dart';
part 'event_view_state.dart';

class EventViewBloc extends Bloc<EventViewEvent, EventViewState> {
  final formKey = GlobalKey<FormState>();

  EventViewBloc(
    OrgFilesCubit orgFilesCubit,
    OrgEntry event,
    OrgTimestamp timestamp,
  ) : super(EventViewState.inital(event, timestamp)) {
    on<EventViewEvent>(
      (event, emit) => switch (event) {
        EventViewTitleChangeEvent() => emit(
          state.copyWith(newEvent: state.newEvent.copyWith(title: event.title)),
        ),
        EventViewChangeTimestamp() => emit(
          state.copyWith(newTimestamp: event.timestamp),
        ),
        EventViewSaveEvent() => save(orgFilesCubit),
      },
    );
  }

  Future<void> save(OrgFilesCubit cubit) async {
    final replacements = <(OrgNode, OrgNode)>[];
    final titleChanged = state.oldEvent.title != state.newEvent.title;
    final timestampChanged = state.oldTimestamp != state.newTimestamp;

    if (state.oldEvent.containsTimestampInHeadline) {
      if (titleChanged || timestampChanged) {
        replacements.add((
          state.oldEvent.section.headline.title! as OrgNode,
          OrgContent([OrgPlainText(state.newEvent.title), state.newTimestamp]),
        ));
      }
    } else {
      if (timestampChanged) {
        replacements.add((state.oldTimestamp, state.newTimestamp));
      }
      if (titleChanged) {
        replacements.add((
          state.oldEvent.section.headline.title! as OrgNode,
          OrgContent([OrgPlainText(state.newEvent.title)]),
        ));
      }
    }

    await cubit.replaceNodes(state.oldEvent.fileInfo, replacements);
  }
}
