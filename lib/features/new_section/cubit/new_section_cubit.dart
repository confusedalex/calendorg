import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:org_parser/org_parser.dart';

part 'new_section_state.dart';

class NewSectionCubit extends Cubit<NewSectionState> {
  NewSectionCubit(String? title, OrgTimestamp? timestamp)
      : super(NewSectionState(title: title, timestamp: timestamp));

  void changeTitle(String newTitle) =>
      emit(state.copyWith(title: () => newTitle));

  void changeTimestamp(OrgTimestamp timestamp) =>
      emit(state.copyWith(timestamp: () => timestamp));
}
