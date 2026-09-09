import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/files/cubit/org_files_cubit.dart';
import '../../../../core/files/services/org_file_service.dart';
import '../../../../shared/config/preferences_service.dart';

class DebugPage extends StatelessWidget {
  const DebugPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          ListTile(
            title: const Text('Show SharedPreferences'),
            onTap: () async {
              final prefs = await context.read<PreferencesService>().getAll();

              if (context.mounted) {
                await showDialog(
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
              title: const Text('Show loaded FilePaths'),
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
              title: const Text('Show loaded Documents'),
              onTap: () async {
                final fileService = context.read<OrgFileService>();
                await showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    content: SingleChildScrollView(
                      child: Column(
                        children: state.filePaths
                            .map(
                              (fileInfo) => FutureBuilder<String>(
                                future: fileService.readText(
                                  fileInfo.identifier,
                                ),
                                builder: (context, snapshot) =>
                                    Text(snapshot.data ?? 'Loading...'),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          BlocBuilder<OrgFilesCubit, OrgFilesState>(
            builder: (context, state) => ListTile(
              title: const Text('Show loaded events'),
              onTap: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  content: SingleChildScrollView(
                    child: Text(state.entries.toString()),
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
