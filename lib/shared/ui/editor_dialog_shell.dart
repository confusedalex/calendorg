import 'dart:math';

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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final width = min<double>(
      MediaQuery.sizeOf(context).width * widthFactor,
      480,
    );

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      titlePadding: EdgeInsets.fromLTRB(24, 24, showClose ? 12 : 24, 16),
      contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        spacing: 12,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(titleIcon, size: 22, color: colors.onPrimaryContainer),
          ),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (showClose) const CloseButton(),
        ],
      ),
      content: SizedBox(width: width, child: content),
      actions: actions.isEmpty ? null : actions,
    );
  }
}

class DialogSectionLabel extends StatelessWidget {
  final String text;
  final Color? color;
  const DialogSectionLabel(this.text, {super.key, this.color});

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: Theme.of(context).textTheme.labelLarge!.copyWith(
      color: color ?? Theme.of(context).colorScheme.onSurfaceVariant,
    ),
  );
}
