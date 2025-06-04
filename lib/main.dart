import 'dart:io';

import 'package:calendorg/event.dart';
import 'package:calendorg/models/document_model.dart';
import 'package:calendorg/models/tag_model.dart';
import 'package:calendorg/features/calendar/calendar_page.dart';
import 'package:calendorg/pages/event_list_page.dart';
import 'package:calendorg/pages/settings/settings_page.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:org_parser/org_parser.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
                create: (context) => TagColorsCubit()..setInitialTagColor()),
            BlocProvider(
              create: (context) => OrgDocumentCubit(OrgDocument.parse("")),
            )
          ],
          child: MyHomePage(title: "calendorg"),
        ));
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      orgFile = File(result.files.single.path!);
      var fileContent = await orgFile.readAsString();
      var document = OrgDocument.parse(fileContent);

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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              // onPressed: reload,
              onPressed: () => print('is ja gut'),
              tooltip: 'Reload',
              child: const Icon(Icons.refresh),
            ),
          ],
        ),
      ),
    ));
  }
}
