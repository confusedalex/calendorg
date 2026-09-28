import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/ui/editor_dialog_shell.dart';
import '../../../../util.dart';
import '../model/theme_bloc.dart';

class ThemeDialog extends StatelessWidget {
  const ThemeDialog({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<ThemeBloc, ThemeMode>(
    builder: (context, state) {
      void changeTheme(ThemeMode? theme) =>
          context.read<ThemeBloc>().add(ThemeSwitchEvent(theme!));
      return DialogShell(
        title: context.l10n.choose_theme,
        titleIcon: Icons.sunny,
        showClose: true,
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
                      title: Text(context.l10n.theme_dark),
                      value: ThemeMode.dark,
                      key: const Key('ThemeRadioDarkTheme'),
                    ),
                    RadioListTile(
                      title: Text(context.l10n.theme_light),
                      key: const Key('ThemeRadioLightTheme'),
                      value: ThemeMode.light,
                    ),
                    RadioListTile(
                      title: Text(context.l10n.theme_automatic),
                      key: const Key('ThemeRadioGreenTheme'),
                      value: ThemeMode.system,
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
