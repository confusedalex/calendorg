import 'dart:io';

import 'package:calendorg/DocumentSingelton.dart';
import 'package:calendorg/event.dart';
import 'package:calendorg/pages/CalendarPage.dart';
import 'package:calendorg/pages/EventListPage.dart';
import 'package:calendorg/util.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
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
      home: MyHomePage(title: "calendorg"),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title});
  final String title;
  final Documentsingelton documentSingelton = Documentsingelton();

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String display = "No Document loaded";
  int index = 0;
  List<Event> eventList = [];
  late File orgFile;

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
        widget.documentSingelton.setDocument(document);
        display = fileContent;
      });
    }
  }

  void reload() async {
    var fileContent = await orgFile.readAsString();
    var document = OrgDocument.parse(fileContent);

    setState(() {
      widget.documentSingelton.setDocument(document);
      display = fileContent;
    });

    setState(() {
      eventList = parseEvents(document);
    });
  }

  @override
  Widget build(BuildContext context) {
    final List pages = [eventListPage(display), CalendarPage(eventList)];

    return Scaffold(
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        onDestinationSelected:
            (value) => setState(() {
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
              onPressed: reload,
              tooltip: 'Reload',
              child: const Icon(Icons.refresh),
            ),
          ],
        ),
      ),
    );
  }
}
