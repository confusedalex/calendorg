import 'package:flutter/material.dart';

class DialogShell extends StatelessWidget {
  final String title;
  final IconData titleIcon;
  final Widget content;
  final List<Widget> actions;
  final double widthFactor;
  final bool showClose;

  const DialogShell({
    super.key,
    required this.title,
    required this.titleIcon,
    required this.content,
    this.actions = const [],
    this.widthFactor = 0.75,
    this.showClose = false,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      titlePadding: EdgeInsets.fromLTRB(24, 24, 24, 12),
      contentPadding: EdgeInsets.fromLTRB(24, 0, 24, 8),
      actionsPadding: EdgeInsets.fromLTRB(24, 0, 24, 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              titleIcon,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text(title)],
            ),
          ),
          if (showClose) CloseButton(),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * widthFactor,
        child: content,
      ),
      actions: actions,
    );
  }
}
