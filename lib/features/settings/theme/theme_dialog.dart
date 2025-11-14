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
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.75,
          child: ListView(
            shrinkWrap: true,
            children: [
              RadioGroup(
                groupValue: state,
                onChanged: changeTheme,
                child: Column(
                  children: [
                    RadioListTile(
                      title: Text("dark"),
                      value: ThemeData.dark(),
                      key: Key("ThemeRadioDarkTheme"),
                    ),
                    RadioListTile(
                      title: Text("light"),
                      key: Key("ThemeRadioLightTheme"),
                      value: ThemeData.light(),
                    ),
                    RadioListTile(
                      title: Text("green"),
                      key: Key("ThemeRadioGreenTheme"),
                      value: ThemeData.from(
                        colorScheme: ColorScheme.fromSeed(
                          seedColor: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
