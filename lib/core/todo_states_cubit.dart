import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:org_parser/org_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

final defaultTodoStates = OrgTodoStatesWithIgnored(
  todo: ['TODO'],
  done: ['DONE'],
  ignored: [],
);

class TodoStatesCubit extends Cubit<OrgTodoStatesWithIgnored> {
  TodoStatesCubit() : super(defaultTodoStates) {
    loadFromPrefs();
  }

  Future<void> loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> todo = List.from(
        jsonDecode(prefs.getString('todoStates') ?? '[]'),
      );
      final List<String> done = List.from(
        jsonDecode(prefs.getString('doneStates') ?? '[]'),
      );
      final List<String> ignored = List.from(
        jsonDecode(prefs.getString('ignoredStates') ?? '[]'),
      );

      final states = todo.isEmpty && done.isEmpty
          ? defaultTodoStates
          : OrgTodoStatesWithIgnored(todo: todo, done: done, ignored: ignored);
      emit(states);
    } on Exception catch (e) {
      emit(defaultTodoStates);
    }
  }

  void addTodo(String status, String keyword) {
    if (status == 'todo') {
      emit(
        OrgTodoStatesWithIgnored(
          todo: [...state.todo, keyword],
          done: state.done,
          ignored: state.ignored,
        ),
      );
    } else if (status == 'done') {
      emit(
        OrgTodoStatesWithIgnored(
          todo: state.todo,
          done: [...state.done, keyword],
          ignored: state.ignored,
        ),
      );
    } else if (status == 'ignored') {
      emit(
        OrgTodoStatesWithIgnored(
          todo: state.todo,
          done: state.done,
          ignored: [...state.ignored, keyword],
        ),
      );
    }
    saveToPrefs();
  }

  void removeTodo(String status, String keyword) {
    if (status == 'todo') {
      emit(
        OrgTodoStatesWithIgnored(
          todo: state.todo.where((e) => e != keyword).toList(),
          done: state.done,
          ignored: state.ignored,
        ),
      );
    } else if (status == 'done') {
      emit(
        OrgTodoStatesWithIgnored(
          todo: state.todo,
          done: state.done.where((e) => e != keyword).toList(),
          ignored: state.ignored,
        ),
      );
    } else if (status == 'ignored') {
      emit(
        OrgTodoStatesWithIgnored(
          todo: state.todo,
          done: state.done,
          ignored: state.ignored.where((e) => e != keyword).toList(),
        ),
      );
    }
    saveToPrefs();
  }

  Future<void> saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('todoStates', jsonEncode(state.todo));
      await prefs.setString('doneStates', jsonEncode(state.done));
      await prefs.setString('ignoredStates', jsonEncode(state.ignored));
    } on Exception catch (e) {
      debugPrint('Error saving todo states: $e');
    }
  }
}

class OrgTodoStatesWithIgnored {
  final List<String> todo;
  final List<String> done;
  final List<String> ignored;
  OrgTodoStates get todoStates =>
      OrgTodoStates(todo: [...todo, ...ignored], done: done);

  OrgTodoStatesWithIgnored({
    required this.todo,
    required this.done,
    required this.ignored,
  });
}
