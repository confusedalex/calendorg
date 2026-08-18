import 'package:bloc/bloc.dart';
import 'new_tag_color_state.dart';
import 'package:flutter/material.dart';

class NewTagColorCubit extends Cubit<NewTagColorState> {
  NewTagColorCubit() : super(NewTagColorState(color: Colors.blue, text: ''));

  void updateText(String text) => emit(state.copyWith(text: text));
  void updateColor(Color color) => emit(state.copyWith(color: color));
}
