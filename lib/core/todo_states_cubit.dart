import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import '../entities/todo_states/todo_states.dart';
import '../entities/todo_states/todo_states_ignored.dart';
import '../shared/config/preferences_service.dart';

final defaultTodoStates = OrgTodoStatesWithIgnored(
  todo: ['TODO'],
  done: ['DONE'],
  ignored: [],
);

class TodoStatesCubit extends Cubit<OrgTodoStatesWithIgnored> {
  TodoStatesCubit(this._prefs) : super(defaultTodoStates);

  final PreferencesService _prefs;

  Future<void> loadFromPrefs() async {
    try {
      final List<String> todo = List.from(
        jsonDecode(await _prefs.getString(PrefKeys.todoStates) ?? '[]'),
      );
      final List<String> done = List.from(
        jsonDecode(await _prefs.getString(PrefKeys.doneStates) ?? '[]'),
      );
      final List<String> ignored = List.from(
        jsonDecode(await _prefs.getString(PrefKeys.ignoredStates) ?? '[]'),
      );

      final states = todo.isEmpty && done.isEmpty
          ? defaultTodoStates
          : OrgTodoStatesWithIgnored(todo: todo, done: done, ignored: ignored);
      emit(states);
    } on Exception {
      emit(defaultTodoStates);
    }
  }

  Future<void> addTodo(TodoStatus status, String keyword) async {
    switch (status) {
      case TodoStatus.todo:
        emit(
          OrgTodoStatesWithIgnored(
            todo: [...state.todo, keyword],
            done: state.done,
            ignored: state.ignored,
          ),
        );
      case TodoStatus.done:
        emit(
          OrgTodoStatesWithIgnored(
            todo: state.todo,
            done: [...state.done, keyword],
            ignored: state.ignored,
          ),
        );
      case TodoStatus.ignored:
        emit(
          OrgTodoStatesWithIgnored(
            todo: state.todo,
            done: state.done,
            ignored: [...state.ignored, keyword],
          ),
        );
    }
    await saveToPrefs();
  }

  Future<void> removeTodo(TodoStatus status, String keyword) async {
    switch (status) {
      case TodoStatus.todo:
        emit(
          OrgTodoStatesWithIgnored(
            todo: state.todo.where((e) => e != keyword).toList(),
            done: state.done,
            ignored: state.ignored,
          ),
        );
      case TodoStatus.done:
        emit(
          OrgTodoStatesWithIgnored(
            todo: state.todo,
            done: state.done.where((e) => e != keyword).toList(),
            ignored: state.ignored,
          ),
        );
      case TodoStatus.ignored:
        emit(
          OrgTodoStatesWithIgnored(
            todo: state.todo,
            done: state.done,
            ignored: state.ignored.where((e) => e != keyword).toList(),
          ),
        );
    }
    await saveToPrefs();
  }

  Future<void> saveToPrefs() async {
    try {
      await _prefs.setString(PrefKeys.todoStates, jsonEncode(state.todo));
      await _prefs.setString(PrefKeys.doneStates, jsonEncode(state.done));
      await _prefs.setString(PrefKeys.ignoredStates, jsonEncode(state.ignored));
    } on Exception catch (e) {
      debugPrint('Error saving todo states: $e');
    }
  }
}
