import 'package:bloc/bloc.dart';

part 'diff_view_state.dart';

class DiffViewCubit extends Cubit<DiffViewState> {
  DiffViewCubit() : super(DiffViewState(oldText: null));

  void changeOldText(String text) {
    emit(DiffViewState(oldText: text));
  }
}
