import 'package:flutter/material.dart';

class EditorDialogShell extends StatelessWidget {
  final Widget title;
  final Widget content;
  final List<Widget> actions;
  final double widthFactor;

  const EditorDialogShell({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
    this.widthFactor = 0.75,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      titlePadding: EdgeInsets.fromLTRB(24, 24, 24, 12),
      contentPadding: EdgeInsets.fromLTRB(24, 0, 24, 8),
      actionsPadding: EdgeInsets.fromLTRB(24, 0, 24, 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: title,
      content: SizedBox(
        width: MediaQuery.of(context).size.width * widthFactor,
        child: content,
      ),
      actions: actions,
    );
  }
}
