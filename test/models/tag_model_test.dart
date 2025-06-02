import 'dart:convert';

import 'package:calendorg/event.dart';
import 'package:calendorg/models/tag_model.dart';
import 'package:calendorg/tag_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

final schoolTagColor = TagColor("school", Colors.orange);

Future<void> main() async {
  Future<TagColorsCubit> getTagColorsCubit() async {
    SharedPreferences.setMockInitialValues({
      "tagColors": jsonEncode([schoolTagColor])
    });

    var tagColorsModel = TagColorsCubit()..setInitialTagColor();

    // wait for async to finish, I don't know how to do this better :/
    await Future.delayed(Duration(milliseconds: 10));

    return tagColorsModel;
  }

  test("Tags will be loaded from shared preferences", () async {
    final tagColorsModel = await getTagColorsCubit();

    expect(tagColorsModel.state.first.toString(),
        equals(schoolTagColor.toString()));
  });

  test("Add tag to model will add to list and save to prefs", () async {
    final tagColorsModel = await getTagColorsCubit();
    final newTag = TagColor("new green tag", Colors.green);

    tagColorsModel.addTagColor(TagColor("new green tag", Colors.green));
    var tagsColorsFromPrefs =
        (jsonDecode(tagColorsModel.prefs.getString("tagColors") ?? "[]")
                as List)
            .map((tagColor) => TagColor.fromJson(tagColor))
            .toList();

    expect(tagColorsModel.state, containsAll([schoolTagColor, newTag]));
    expect(tagsColorsFromPrefs, containsAll([schoolTagColor, newTag]));
  });

  test("Adding tag with same name wont add a new tag", () async {
    final tagColorsModel = await getTagColorsCubit();
    final newSchoolTag = TagColor("school", Colors.green);

    tagColorsModel.addTagColor(newSchoolTag);

    expect(tagColorsModel.state, contains(newSchoolTag));
  });

  test("deleting tag work", () async {
    final tagColorsModel = await getTagColorsCubit();

    tagColorsModel.removeTagColor(schoolTagColor.tag);

    expect(tagColorsModel.state, isEmpty);
  });

  group("getColor tests", () {
    test("Correct color for event will be returned", () async {
      final tagColorsModel = await getTagColorsCubit();

      var schoolEvent = FakeEvent(["school"]);

      expect(tagColorsModel.getTagColor(schoolEvent),
          isSameColorAs(schoolTagColor.color));
    });

    test("Default color gets returned, when no TagColor matches the tag",
        () async {
      final tagColorsModel = await getTagColorsCubit();

      var homeEvent = FakeEvent(["@home"]);

      expect(tagColorsModel.getTagColor(homeEvent), isSameColorAs(Colors.blue));
    });

    test(
        "When multiple matching tags, the tag closest to index 0 gets returned",
        () async {
      final tagColorsModel = await getTagColorsCubit();
      tagColorsModel.addTagColor(TagColor("@home", Colors.green));

      var event = FakeEvent(["@home", "school"]);

      expect(tagColorsModel.getTagColor(event),
          isSameColorAs(schoolTagColor.color));
    });
  });

  test("reordering will reorder correctly", () async {
    final homeTagColor = TagColor("@home", Colors.green);
    final tagColorsModel = await getTagColorsCubit();
    tagColorsModel.addTagColor(homeTagColor);

    expect(tagColorsModel.state.first, schoolTagColor);
    tagColorsModel.reorder(0, 2);
    expect(tagColorsModel.state.first, homeTagColor);
  });
}

class FakeEvent extends Fake implements Event {
  @override
  List<String> tags;

  FakeEvent(this.tags);
}
