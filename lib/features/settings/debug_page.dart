import 'package:calendorg/core/files/cubit/org_files_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DebugPage extends StatelessWidget {
  const DebugPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          ListTile(
            title: Text("Show SharedPreferences"),
            onTap: () async {
              final prefs = await SharedPreferencesAsync().getAll();

              if (context.mounted) {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    content: SingleChildScrollView(
                      child: Column(
                        children: prefs.entries
                            .map(
                              (e) => Text(
                                "${e.key}:${e.value.toString().replaceAll(RegExp('"identifier":".+?",'), '')}",
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                );
              }
            },
          ),
          BlocBuilder<OrgFilesCubit, OrgFilesState>(
            builder: (context, state) => ListTile(
              title: Text("Show loaded FilePaths"),
              onTap: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  content: SingleChildScrollView(
                    child: Column(
                      children: state.filePaths
                          .map((e) => Text(e.toString()))
                          .toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),
          BlocBuilder<OrgFilesCubit, OrgFilesState>(
            builder: (context, state) => ListTile(
              title: Text("Show loaded Documents"),
              onTap: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  content: SingleChildScrollView(
                    child: Column(
                      children: state.documentsMap.entries
                          .map((e) => Text(e.value.toMarkup()))
                          .toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),
          BlocBuilder<OrgFilesCubit, OrgFilesState>(
            builder: (context, state) => ListTile(
              title: Text("Show loaded events"),
              onTap: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  content: SingleChildScrollView(
                    child: Text(state.allEvents.entries.toString()),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
