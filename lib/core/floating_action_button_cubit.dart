import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

class FloatingActionButtonCubit extends Cubit<FloatingActionButton?> {
  FloatingActionButtonCubit() : super(null);

  void changeButton(FloatingActionButton? button) => emit(button);
}
