import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:org_parser/org_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

final defaultTodoStates = OrgTodoStates(todo: ["TODO"], done: ["DONE"]);

class TodoStatesCubit extends Cubit<OrgTodoStates> {
  TodoStatesCubit() : super(defaultTodoStates);

  Future<void> loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> todo = List.from(
        jsonDecode(prefs.getString("todoStates") ?? "[]"),
      );
      final List<String> done = List.from(
        jsonDecode(prefs.getString("doneStates") ?? "[]"),
      );

      emit(
        todo.isEmpty && done.isEmpty
            ? defaultTodoStates
            : OrgTodoStates(todo: todo, done: done),
      );
    } catch (e) {
      emit(defaultTodoStates);
    }
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

  Future<void> saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("todoStates", jsonEncode(state.todo));
      await prefs.setString("doneStates", jsonEncode(state.done));
    } catch (e) {
      debugPrint('Error saving todo states: $e');
    }
  }
}
