import 'package:calendorg/core/tag_colors/tag_colors_cubit.dart';
import 'package:calendorg/event.dart';
import 'package:calendorg/core/tag_colors/tag_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EventMarkers extends StatelessWidget {
  final List<Event> eventList;
  const EventMarkers({super.key, required this.eventList});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TagColorsCubit, List<TagColor>>(
        builder: (context, state) {
      return FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 1,
              children: eventList
                  .map(context.read<TagColorsCubit>().getTagColor)
                  .toSet()
                  .map((color) => BlocBuilder<TagColorsCubit, List<TagColor>>(
                      builder: (context, state) =>
                          CircleAvatar(radius: 7, backgroundColor: color)))
                  .toList()));
    });
  }
}
