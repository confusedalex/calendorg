import 'package:test/test.dart';
import 'package:calendorg/features/settings/todo_state/todo_state_add_dialog_cubit.dart';

void main() {
  group("todo_state_add_dialog_cubit_test", () {
    test('Changing text works', () {
      final cubit = TodoStateAddDialogCubit();

      cubit.updateText("new text");

      expect(cubit.state, equals("new text"));
    });
  });
}
