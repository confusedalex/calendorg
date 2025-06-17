import 'dart:io';

import 'package:calendorg/core/tag_colors/tag_colors_cubit.dart';
import 'package:calendorg/event.dart';
import 'package:calendorg/core/document/document_cubit.dart';
import 'package:calendorg/features/calendar/calendar_page.dart';
import 'package:calendorg/features/event_list_page.dart';
import 'package:calendorg/features/settings/settings_page.dart';
import 'package:calendorg/core/starting_day_cubit.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:org_parser/org_parser.dart';

void main() {
  runApp(const Calendorg());
}

class Calendorg extends StatelessWidget {
  const Calendorg({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'calendorg',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        ),
        home: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => StartingDayCubit()..loadStartingDay(),
            ),
            BlocProvider(
                create: (context) => TagColorsCubit()..setInitialTagColor()),
            BlocProvider(
              create: (context) => OrgDocumentCubit(OrgDocument.parse("")),
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
  List<Event> eventList = [];
  late File orgFile;
  String firstRead = "loading";

  @override
  void initState() {
    super.initState();
    loadAsset();
  }

  void loadAsset() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      orgFile = File(result.files.single.path!);
      final fileContent = await orgFile.readAsString();
      final document = OrgDocument.parse(fileContent);

      setState(() {
        BlocProvider.of<OrgDocumentCubit>(context).setDocument(document);
        firstRead = fileContent;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List pages = [
      eventListPage(firstRead),
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
