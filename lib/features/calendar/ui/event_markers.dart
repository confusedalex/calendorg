import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/settings/settings_cubit.dart';
import '../../../entities/occurrence/occurrence.dart';

class EventMarkers extends StatelessWidget {
  final List<Occurrence> occurrences;
  const EventMarkers({super.key, required this.occurrences});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    final colors = occurrences
        .map((o) => o.entry)
        .toSet()
        .map(settings.tagColorOf)
        .toSet();
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 2,
          children: colors
              .map((color) => CircleAvatar(radius: 4, backgroundColor: color))
              .toList(),
        ),
      ),
    );
  }
}
