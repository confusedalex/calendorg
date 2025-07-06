import 'package:calendorg/core/cubit/floating_action_button_cubit.dart';
import 'package:calendorg/core/tag_colors/tag_colors_cubit.dart';
import 'package:calendorg/features/settings/settings_page.dart';
import 'package:calendorg/features/settings/tags/tags_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'Settings Page Test',
    () {
      group('Tag Colors', () {
        testWidgets("Find Tag Colors Button", (tester) async {
          await tester.pumpWidget(BlocProvider(
            create: (context) => FloatingActionButtonCubit(),
            child: MaterialApp(home: Scaffold(body: SettingsPage())),
          ));

          await tester.pumpAndSettle();

          expect(find.text("Tag Colors"), findsOneWidget);
        });

        testWidgets("Tapping Button open Dialog", (tester) async {
          await tester.pumpWidget(MaterialApp(
              home: Scaffold(
                  body: MultiBlocProvider(providers: [
            BlocProvider(
              create: (context) => TagColorsCubit(),
            ),
            BlocProvider(create: (context) => FloatingActionButtonCubit())
          ], child: SettingsPage()))));

          await tester.pumpAndSettle();
          await tester.tap(find.text("Tag Colors"));

          await tester.pumpAndSettle();

          expect(find.byType(TagsPage), findsOneWidget);
        });
      });
    },
  );
}
