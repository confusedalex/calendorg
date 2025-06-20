import 'package:calendorg/core/files/bloc/org_files_bloc.dart';
import 'package:calendorg/core/tag_colors/tag_colors_cubit.dart';
import 'package:calendorg/features/calendar/calendar_page.dart';
import 'package:calendorg/features/event_list_page.dart';
import 'package:calendorg/features/settings/settings_page.dart';
import 'package:calendorg/core/starting_day_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const Calendorg());
}

class Calendorg extends StatelessWidget {
  const Calendorg({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'calendorg',
        home: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => StartingDayCubit()..loadStartingDay(),
            ),
            BlocProvider(
                create: (context) => TagColorsCubit()..setInitialTagColor()),
            BlocProvider(
              create: (context) => OrgFilesBloc()..add(OrgFilesInit()),
            )
          ],
          child: HomePage(),
        ));
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
      eventListPage(),
      CalendarPage(DateTime.now()),
      SettingsPage()
    ];
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
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    ));
  }
}
