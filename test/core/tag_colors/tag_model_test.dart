import 'dart:convert';

import 'package:calendorg/core/tag_colors/tag_model.dart';
import 'package:calendorg/event.dart';
import 'package:calendorg/core/tag_colors/tag_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

final schoolTagColor = TagColor("school", Colors.orange);
final homeTagColor = TagColor("@home", Colors.green);

Future<void> main() async {
  Future<TagColorsCubit> getTagColorsCubit() async {
    SharedPreferences.setMockInitialValues({
      "tagColors": jsonEncode([schoolTagColor])
    });

    var cubit = TagColorsCubit()..setInitialTagColor();

    // wait for async to finish, I don't know how to do this better :/
    await Future.delayed(Duration(milliseconds: 10));

    return cubit;
  }

  group(
    'TagModel',
    () {
      test("Tags will be loaded from shared preferences", () async {
        final cubit = await getTagColorsCubit();

        expect(cubit.state.first, equals(schoolTagColor));
      });

      test("Add tag to model will add to list and save to prefs", () async {
        final cubit = await getTagColorsCubit();
        final newTag = TagColor("new green tag", Colors.green);

        cubit.addTagColor(TagColor("new green tag", Colors.green));
        var tagsColorsFromPrefs =
            (jsonDecode(cubit.prefs.getString("tagColors") ?? "[]") as List)
                .map((tagColor) => TagColor.fromJson(tagColor))
                .toList();

        expect(cubit.state, containsAll([schoolTagColor, newTag]));
        expect(tagsColorsFromPrefs, containsAll([schoolTagColor, newTag]));
      });

      test("Adding tag with same name wont add a new tag", () async {
        final cubit = await getTagColorsCubit();
        final newSchoolTag = TagColor("school", Colors.green);

        cubit.addTagColor(newSchoolTag);

        expect(cubit.state, contains(newSchoolTag));
      });

      test("deleting tag work", () async {
        final cubit = await getTagColorsCubit();

        cubit.removeTagColor(schoolTagColor.tag);

        expect(cubit.state, isEmpty);
      });

      group("getColor tests", () {
        test("Correct color for event will be returned", () async {
          final cubit = await getTagColorsCubit();

          var schoolEvent = FakeEvent(["school"]);

          expect(cubit.getTagColor(schoolEvent),
              isSameColorAs(schoolTagColor.color));
        });

        test("Default color gets returned, when no TagColor matches the tag",
            () async {
          final cubit = await getTagColorsCubit();

          var homeEvent = FakeEvent(["@home"]);

          expect(cubit.getTagColor(homeEvent), isSameColorAs(Colors.blue));
        });

        test(
            "When multiple matching tags, the tag closest to index 0 gets returned",
            () async {
          final cubit = await getTagColorsCubit();
          cubit.addTagColor(homeTagColor);

          var event = FakeEvent(["@home", "school"]);

          expect(cubit.getTagColor(event), isSameColorAs(schoolTagColor.color));
        });
      });

      test("reordering will reorder correctly", () async {
        final cubit = await getTagColorsCubit();
        cubit.addTagColor(homeTagColor);

        expect(cubit.state.first, schoolTagColor);
        cubit.reorder(0, 2);
        expect(cubit.state.first, homeTagColor);
      });

      test("getTagColorByName will return correct color", () async {
        final cubit = await getTagColorsCubit();

        expect(cubit.getTagColorByName(schoolTagColor.tag),
            isSameColorAs(schoolTagColor.color));
      });
    },
  );
}

class FakeEvent extends Fake implements Event {
  @override
  List<String> tags;

  FakeEvent(this.tags);
}
