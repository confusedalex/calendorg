import 'dart:ui';

import 'package:bloc/bloc.dart';

class FloatingActionButtonCubit extends Cubit<VoidCallback?> {
  FloatingActionButtonCubit() : super(null);

  void changeOnClick(VoidCallback? function) => emit(function);
}
