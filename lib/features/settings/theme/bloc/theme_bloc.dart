import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

part 'theme_event.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeData> {
  ThemeBloc() : super(ThemeData.dark()) {
    on<ThemeEvent>((event, emit) {
      switch (event) {
        case ThemeSwitchEvent():
          emit(event.theme);
      }
    });
  }
}
