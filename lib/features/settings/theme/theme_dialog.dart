import 'package:calendorg/features/settings/theme/bloc/theme_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeDialog extends StatelessWidget {
  const ThemeDialog({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<ThemeBloc, ThemeData>(
        builder: (context, state) {
          void changeTheme(ThemeData? theme) =>
              context.read<ThemeBloc>().add(ThemeSwitchEvent(theme!));
          return AlertDialog(
            title: Row(children: [Text("Themes"), Spacer(), CloseButton()]),
            content: Flex(
              direction: Axis.vertical,
              children: [
                RadioListTile(
                    title: Text("dark"),
                    value: ThemeData.dark(),
                    key: Key("ThemeRadioDarkTheme"),
                    groupValue: state,
                    onChanged: changeTheme),
                RadioListTile(
                    title: Text("light"),
                    key: Key("ThemeRadioLightTheme"),
                    value: ThemeData.light(),
                    groupValue: state,
                    onChanged: changeTheme),
                RadioListTile(
                    title: Text("green"),
                    key: Key("ThemeRadioGreenTheme"),
                    value: ThemeData.from(
                        colorScheme:
                            ColorScheme.fromSeed(seedColor: Colors.green)),
                    groupValue: state,
                    onChanged: changeTheme),
              ],
            ),
          );
        },
      );
}
