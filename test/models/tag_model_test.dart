import 'dart:collection';
import 'dart:convert';

import 'package:calendorg/models/tag_model.dart';
import 'package:calendorg/tag_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

final schoolTagColor = TagColor("school", Colors.orange);

Future<void> main() async {
  Future<TagColorsModel> getTagColorsModel() async {
    SharedPreferences.setMockInitialValues({
      "tagColors": jsonEncode([schoolTagColor])
    });

    var tagColorsModel = TagColorsModel();

    // wait for async to finish, I don't know how to do this better :/
    await Future.delayed(Duration(milliseconds: 10));

    return tagColorsModel;
  }

  test("Tags will be loaded from shared preferences", () async {
    final tagColorsModel = await getTagColorsModel();

    expect(tagColorsModel.tagColorsFromPrefs.first.toString(),
        equals(schoolTagColor.toString()));
  });

  test("Add tag to model will add to list and save to prefs", () async {
    final tagColorsModel = await getTagColorsModel();
    final newTag = TagColor("new green tag", Colors.green);

    tagColorsModel.addTagColor(TagColor("new green tag", Colors.green));
    var tagsColorsFromPrefs =
        (jsonDecode(tagColorsModel.prefs.getString("tagColors") ?? "[]")
                as List)
            .map((tagColor) => TagColor.fromJson(tagColor))
            .toList();

    expect(tagColorsModel.tagColorsFromPrefs,
        containsAll([schoolTagColor, newTag]));
    expect(tagsColorsFromPrefs, containsAll([schoolTagColor, newTag]));
  });

  test("Adding tag with same name wont add a new tag", () async {
    final tagColorsModel = await getTagColorsModel();
    final newSchoolTag = TagColor("school", Colors.green);

    tagColorsModel.addTagColor(newSchoolTag);

    expect(tagColorsModel.tagColorsFromPrefs, contains(newSchoolTag));
  });

  test("deleting tag work", () async {
    final tagColorsModel = await getTagColorsModel();

    tagColorsModel.removeTagColor(schoolTagColor.tag);

    expect(tagColorsModel.tagColorsFromPrefs, isEmpty);
  });
}
