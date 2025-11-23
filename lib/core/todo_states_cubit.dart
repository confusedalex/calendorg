import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:org_parser/org_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

final defaultTodoStates = OrgTodoStates(todo: ["TODO"], done: ["DONE"]);

class TodoStatesCubit extends Cubit<OrgTodoStates> {
  TodoStatesCubit() : super(defaultTodoStates);

  void loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> todo = List.from(
      jsonDecode(prefs.getString("todoStates") ?? "[]"),
    );
    final List<String> done = List.from(
      jsonDecode(prefs.getString("doneStates") ?? "[]"),
    );

    return emit(
      todo.isEmpty && done.isEmpty
          ? defaultTodoStates
          : OrgTodoStates(todo: todo, done: done),
    );
  }

  void addTodo(String status, String keyword) {
    if (status == "todo") {
      emit(OrgTodoStates(done: state.done, todo: [...state.todo, keyword]));
    } else if (status == "done") {
      emit(OrgTodoStates(todo: state.todo, done: [...state.done, keyword]));
    }
    saveToPrefs();
  }

  void removeTodo(String status, String keyword) {
    if (status == "todo") {
      emit(
        OrgTodoStates(
          done: state.done,
          todo: state.todo.where((e) => e != keyword),
        ),
      );
    } else if (status == "done") {
      emit(
        OrgTodoStates(
          todo: state.todo,
          done: state.done.where((e) => e != keyword),
        ),
      );
    }
    saveToPrefs();
  }

  void saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("todoStates", jsonEncode(state.todo));
    prefs.setString("doneStates", jsonEncode(state.done));
  }
}
