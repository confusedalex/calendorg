import 'dart:collection';
import 'dart:convert';

import 'package:calendorg/tag_color.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TagColorsModel extends ChangeNotifier {
  final List<TagColor> _tagColors = [];
  late final SharedPreferences prefs;

  TagColorsModel() {
    loadTags();
  }

  UnmodifiableListView<TagColor> get tagColorsFromPrefs =>
      UnmodifiableListView(_tagColors);

  void loadTags() async {
    prefs = await SharedPreferences.getInstance();
    var tagColorsFromPrefs =
        (jsonDecode(prefs.getString("tagColors") ?? "[]") as List)
            .map((tagColor) => TagColor.fromJson(tagColor))
            .toList();
    setTagColors(tagColorsFromPrefs);
    notifyListeners();
  }

  void setTagColors(List<TagColor> tagColors) {
    _tagColors.clear();
    _tagColors.addAll(tagColors);
    saveTagsToPrefs();
  }

  void saveTagsToPrefs() async {
    prefs.setString("tagColors", jsonEncode(_tagColors));
    notifyListeners();
  }

  void addTagColor(TagColor tagColor) {
    removeTagColor(tagColor.tag);
    _tagColors.add(tagColor);
    saveTagsToPrefs();
  }

  void removeTagColor(String tagName) {
    _tagColors.removeWhere((tag) => tag.tag == tagName);
    saveTagsToPrefs();
  }

  Color getTagColorByName(String tagName) {
    return _tagColors.firstWhere((tagColor) => tagColor.tag == tagName).color;
  }
}
