import 'package:flutter/material.dart';
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
            },
          ),
        ],
      ),
    );
  }
}
