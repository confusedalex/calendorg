import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:org_parser/org_parser.dart';

import '../../../core/files/cubit/org_files_cubit.dart';
import '../../../entities/org_entry/entry_edit.dart';
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
    final titleChanged = state.oldEvent.title != state.newEvent.title;
    final timestampChanged = state.oldTimestamp != state.newTimestamp;

    final edit = EntryEdit(
      newTitle: titleChanged ? state.newEvent.title : null,
      oldTimestamp: state.oldTimestamp,
      newTimestamp: timestampChanged ? state.newTimestamp : null,
    );
    if (edit.isEmpty) return;

    await cubit.applyEdit(state.oldEvent, edit);
  }
}
