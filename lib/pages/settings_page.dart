import 'package:calendorg/models/tag_model.dart';
import 'package:calendorg/pages/tags_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ChangeNotifierProvider(
                        create: (context) => TagColorsModel(),
                        child: const TagsPage())))),
      ]);
}
