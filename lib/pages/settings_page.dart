import 'package:calendorg/models/tag_model.dart';
import 'package:calendorg/pages/tags_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
                    builder: (_) => BlocProvider.value(
                        value: BlocProvider.of<TagColorsCubit>(context),
                        child: const TagsPage()))))
      ]);
}
