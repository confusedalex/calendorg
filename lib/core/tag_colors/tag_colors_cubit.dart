import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../entities/org_entry/org_entry.dart';
import 'tag_color.dart';

class TagColorsCubit extends Cubit<List<TagColor>> {
  late final SharedPreferences prefs;

  TagColorsCubit() : super([]);
  TagColorsCubit.withInitialValue(super.initialState) {
    loadPrefs();
  }

  Future<void> loadPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<List<TagColor>> loadTags() async {
    try {
      prefs = await SharedPreferences.getInstance();
      return (jsonDecode(prefs.getString('tagColors') ?? '[]') as List)
          .map((tagColor) => TagColor.fromJson(tagColor))
          .toList();
    } on Exception {
      return [];
    }
  }

  Future<void> setInitialTagColor() async {
    emit(await loadTags());
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final currentList = [...state];
    final oldTagColor = currentList[oldIndex];
    currentList.removeAt(oldIndex);
    currentList.insert(newIndex, oldTagColor);
    await saveTagsToPrefs(currentList);
  }

  Future<void> saveTagsToPrefs(List<TagColor> tagColors) async {
    emit(tagColors);
    await prefs.setString('tagColors', jsonEncode(tagColors));
  }

  Future<void> addTagColor(TagColor tagColor) async {
    final newTagColors = [
      ...state.where((t) => t.tag != tagColor.tag),
      tagColor,
    ];
    await saveTagsToPrefs(newTagColors);
  }

  Future<void> removeTagColor(String tagName) async {
    await saveTagsToPrefs([...state.where((tag) => tag.tag != tagName)]);
  }

  Color getTagColorByName(String tagName) {
    return state
        .firstWhere(
          (tagColor) => tagColor.tag == tagName,
          orElse: () => TagColor('', Colors.blue),
        )
        .color;
  }

  Color getTagColor(OrgEntry event) => state
      .firstWhere(
        (tagColor) => event.tags.contains(tagColor.tag),
        orElse: () => TagColor('', Colors.blue),
      )
      .color;
}
