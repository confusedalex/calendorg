import 'dart:convert';
import 'package:calendorg/tag_color.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TagColorsCubit extends Cubit<List<TagColor>> {
  late final SharedPreferences prefs;

  TagColorsCubit() : super([]);
  TagColorsCubit.withInitialValue(super.initialState);

  Future<List<TagColor>> loadTags() async {
    prefs = await SharedPreferences.getInstance();
    return (jsonDecode(prefs.getString("tagColors") ?? "[]") as List)
        .map((tagColor) => TagColor.fromJson(tagColor))
        .toList();
  }

  Future<void> setInitialTagColor() async {
    emit(await loadTags());
  }

  void setTagColors(List<TagColor> tagColors) {
    saveTagsToPrefs(tagColors);
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
}
