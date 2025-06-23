import 'package:calendorg/features/settings/theme/bloc/theme_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeDialog extends StatelessWidget {
  const ThemeDialog({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<ThemeBloc, ThemeData>(
        builder: (context, state) {
          return AlertDialog(
            title: Row(children: [Text("Themes"), Spacer(), CloseButton()]),
            content: Flex(
              direction: Axis.vertical,
              children: [
                ListTile(
                    title: Text("dark"),
                    leading: Radio<ThemeData>(
                        value: ThemeData.dark(),
                        groupValue: state,
                        onChanged: (theme) => context
                            .read<ThemeBloc>()
                            .add(ThemeSwitchEvent(theme!)))),
                ListTile(
                    title: Text("light"),
                    leading: Radio<ThemeData>(
                        value: ThemeData.light(),
                        groupValue: state,
                        onChanged: (theme) => context
                            .read<ThemeBloc>()
                            .add(ThemeSwitchEvent(theme!)))),
                ListTile(
                    title: Text("green"),
                    leading: Radio<ThemeData>(
                        value: ThemeData.from(
                            colorScheme:
                                ColorScheme.fromSeed(seedColor: Colors.green)),
                        groupValue: state,
                        onChanged: (theme) => context
                            .read<ThemeBloc>()
                            .add(ThemeSwitchEvent(theme!)))),
              ],
            ),
          );
        },
      );
}
