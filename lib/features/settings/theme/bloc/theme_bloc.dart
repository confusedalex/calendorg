import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

part 'theme_event.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeMode> {
  ThemeBloc() : super(ThemeMode.system) {
    on<ThemeEvent>((event, emit) {
      switch (event) {
        case ThemeSwitchEvent():
          emit(event.theme);
      }
    });
  }
}
