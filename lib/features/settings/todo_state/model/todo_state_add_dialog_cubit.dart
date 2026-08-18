import 'package:bloc/bloc.dart';

class TodoStateAddDialogCubit extends Cubit<String> {
  TodoStateAddDialogCubit() : super("");

  void updateText(String text) => emit(text);
}
