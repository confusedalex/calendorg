import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/tag_colors/tag_colors_cubit.dart';
import '../../../entities/occurrence/occurrence.dart';

class EventMarkers extends StatelessWidget {
  final List<Occurrence> occurrences;
  const EventMarkers({super.key, required this.occurrences});

  @override
  Widget build(BuildContext context) {
    final tagColors = context.watch<TagColorsCubit>();
    final colors = occurrences
        .map((o) => o.entry)
        .toSet()
        .map(tagColors.getTagColor)
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
