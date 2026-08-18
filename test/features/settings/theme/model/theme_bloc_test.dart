import 'package:bloc_test/bloc_test.dart';
import 'package:calendorg/features/settings/theme/model/theme_bloc.dart';
import 'package:flutter/material.dart';
import 'package:test/test.dart';

void main() {
  group('Theme Bloc', () {
    test(
      'Initial state is dark',
      () => expect(ThemeBloc().state, equals(ThemeMode.system)),
    );

    blocTest(
      'Switching theme works',
      build: ThemeBloc.new,
      act: (bloc) => bloc.add(ThemeSwitchEvent(ThemeMode.light)),
      expect: () => [
        const TypeMatcher<ThemeMode>().having(
          (state) => state,
          'Theme',
          equals(ThemeMode.light),
        ),
      ],
    );
  });
}
