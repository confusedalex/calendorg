import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:test/test.dart';
import 'package:calendorg/features/settings/theme/bloc/theme_bloc.dart';

void main() {
  group("Theme Bloc", () {
    test(
      "Initial state is dark",
      () => expect(ThemeBloc().state, equals(ThemeMode.system)),
    );

    blocTest(
      "Switching theme works",
      build: () => ThemeBloc(),
      act: (bloc) => bloc.add(ThemeSwitchEvent(ThemeMode.light)),
      expect: () => [
        TypeMatcher<ThemeMode>().having(
          (state) => state,
          "Theme",
          equals(ThemeMode.light),
        ),
      ],
    );
  });
}
