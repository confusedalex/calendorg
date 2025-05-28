import 'package:calendorg/pages/TagsPage.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) => Column(children: [
        ListTile(
            title: Text("Tag Colors"),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => const TagsPage())))
      ]);
}
