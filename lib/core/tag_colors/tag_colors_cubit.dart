import 'dart:convert';
import 'package:calendorg/event.dart';
import 'package:calendorg/core/tag_colors/tag_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    prefs = await SharedPreferences.getInstance();
    return (jsonDecode(prefs.getString("tagColors") ?? "[]") as List)
        .map((tagColor) => TagColor.fromJson(tagColor))
        .toList();
  }

  Future<void> setInitialTagColor() async {
    emit(await loadTags());
  }

  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;
    final currentList = [...state];
    final oldTagColor = currentList[oldIndex];
    currentList.removeAt(oldIndex);
    currentList.insert(newIndex, oldTagColor);
    saveTagsToPrefs(currentList);
  }

  void saveTagsToPrefs(List<TagColor> tagColors) async {
    emit(tagColors);
    prefs.setString("tagColors", jsonEncode(tagColors));
  }

  void addTagColor(TagColor tagColor) {
    final newTagColors = [
      ...state.where((t) => t.tag != tagColor.tag),
      tagColor
    ];
    saveTagsToPrefs(newTagColors);
  }

  void removeTagColor(String tagName) {
    saveTagsToPrefs([...state.where((tag) => tag.tag != tagName)]);
  }

  Color getTagColorByName(String tagName) {
    return state.firstWhere((tagColor) => tagColor.tag == tagName).color;
  }

  Color getTagColor(Event event) => state
      .firstWhere((tagColor) => (event).tags.contains(tagColor.tag),
          orElse: () => TagColor("", Colors.blue))
      .color;
}
