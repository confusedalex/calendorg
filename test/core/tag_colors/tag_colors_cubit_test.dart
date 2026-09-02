import 'dart:convert';

import 'package:calendorg/core/tag_colors/tag_color.dart';
import 'package:calendorg/core/tag_colors/tag_colors_cubit.dart';
import 'package:calendorg/entities/org_entry/org_entry.dart';
import 'package:calendorg/shared/config/preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/preferences.dart';

final schoolTagColor = TagColor('school', Colors.orange);
final homeTagColor = TagColor('@home', Colors.green);

Future<void> main() async {
  late PreferencesService prefs;

  Future<TagColorsCubit> getTagColorsCubit() async {
    prefs = inMemoryPreferences({
      'tagColors': jsonEncode([schoolTagColor]),
    });

    final cubit = TagColorsCubit(prefs);
    await cubit.setInitialTagColor();

    return cubit;
  }

  group('TagModel', () {
    test('Tags will be loaded from shared preferences', () async {
      final cubit = await getTagColorsCubit();

      expect(cubit.state.first, equals(schoolTagColor));
    });

    test('Add tag to model will add to list and save to prefs', () async {
      final cubit = await getTagColorsCubit();
      final newTag = TagColor('new green tag', Colors.green);

      await cubit.addTagColor(TagColor('new green tag', Colors.green));
      final stored = await prefs.getString(PrefKeys.tagColors) ?? '[]';
      final tagsColorsFromPrefs = (jsonDecode(stored) as List)
          .map((tagColor) => TagColor.fromJson(tagColor))
          .toList();

      expect(cubit.state, containsAll([schoolTagColor, newTag]));
      expect(tagsColorsFromPrefs, containsAll([schoolTagColor, newTag]));
    });

    test('Adding tag with same name wont add a new tag', () async {
      final cubit = await getTagColorsCubit();
      final newSchoolTag = TagColor('school', Colors.green);

      await cubit.addTagColor(newSchoolTag);

      expect(cubit.state, contains(newSchoolTag));
    });

    test('deleting tag work', () async {
      final cubit = await getTagColorsCubit();

      await cubit.removeTagColor(schoolTagColor.tag);

      expect(cubit.state, isEmpty);
    });

    group('getColor tests', () {
      test('Correct color for event will be returned', () async {
        final cubit = await getTagColorsCubit();

        final schoolEvent = FakeEntry(['school']);

        expect(
          cubit.getTagColor(schoolEvent),
          isSameColorAs(schoolTagColor.color),
        );
      });

      test(
        'Default color gets returned, when no TagColor matches the tag',
        () async {
          final cubit = await getTagColorsCubit();

          final homeEvent = FakeEntry(['@home']);

          expect(cubit.getTagColor(homeEvent), isSameColorAs(Colors.blue));
        },
      );

      test(
        'When multiple matching tags, the tag closest to index 0 gets returned',
        () async {
          final cubit = await getTagColorsCubit();
          await cubit.addTagColor(homeTagColor);

          final event = FakeEntry(['@home', 'school']);

          expect(cubit.getTagColor(event), isSameColorAs(schoolTagColor.color));
        },
      );
    });

    test('reordering will reorder correctly', () async {
      final cubit = await getTagColorsCubit();
      await cubit.addTagColor(homeTagColor);

      expect(cubit.state.first, schoolTagColor);
      await cubit.reorder(0, 1);
      expect(cubit.state.first, homeTagColor);
    });

    test('getTagColorByName will return correct color', () async {
      final cubit = await getTagColorsCubit();

      expect(
        cubit.getTagColorByName(schoolTagColor.tag),
        isSameColorAs(schoolTagColor.color),
      );
    });
  });
}

class FakeEntry extends Fake implements OrgEntryLoaded {
  @override
  List<String> tags;

  FakeEntry(this.tags);
}
