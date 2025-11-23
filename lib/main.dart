import 'package:calendorg/core/floating_action_button_cubit.dart';
import 'package:calendorg/core/files/bloc/org_files_bloc.dart';
import 'package:calendorg/core/tag_colors/tag_colors_cubit.dart';
import 'package:calendorg/core/todo_states_cubit.dart';
import 'package:calendorg/features/calendar/calendar_page.dart';
import 'package:calendorg/features/today_page.dart';
import 'package:calendorg/features/settings/settings_page.dart';
import 'package:calendorg/core/starting_day_cubit.dart';
import 'package:calendorg/features/settings/theme/bloc/theme_bloc.dart';
import 'package:calendorg/l10n/calendorg_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(
    BlocProvider(create: (context) => ThemeBloc(), child: const Calendorg()),
  );
}

class Calendorg extends StatelessWidget {
  const Calendorg({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeData>(
      builder: (context, state) {
        return MaterialApp(
          title: 'calendorg',
          theme: state,
          localizationsDelegates: CalendorgLocalizations.localizationsDelegates,
          supportedLocales: CalendorgLocalizations.supportedLocales,
          home: MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) =>
                    StartingDayCubit()..setInititalStartingDay(),
              ),
              BlocProvider(
                create: (context) => TagColorsCubit()..setInitialTagColor(),
              ),
              BlocProvider(
                create: (context) => TodoStatesCubit()..loadFromPrefs(),
              ),
              BlocProvider(
                create: (context) => OrgFilesBloc()..add(OrgFilesInit()),
              ),
              BlocProvider(create: (context) => FloatingActionButtonCubit()),
            ],
            child: HomePage(),
          ),
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final List pages = [
      todayPage(),
      CalendarPage(DateTime.now()),
      SettingsPage(),
    ];
    return BlocBuilder<FloatingActionButtonCubit, FloatingActionButton?>(
      builder: (context, state) {
        return SafeArea(
          child: Scaffold(
            body: pages[index],
            bottomNavigationBar: NavigationBar(
              onDestinationSelected: (value) => setState(() {
                index = value;
              }),
              selectedIndex: index,
              destinations: [
                NavigationDestination(icon: Icon(Icons.list), label: 'Events'),
                NavigationDestination(
                  icon: Icon(Icons.calendar_today),
                  label: 'Calendar',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            ),
            floatingActionButton: state,
          ),
        );
      },
    );
  }
}
