import 'package:calendorg/core/files/cubit/org_files_cubit.dart';
import 'package:calendorg/features/calendar/event_card.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Widget todayPage() => BlocBuilder<OrgFilesCubit, OrgFilesState>(
  builder: (context, state) => SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Next 3 days",
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.left,
        ),
        ...state
            .eventsByDateWithTimestamps(DateTime.now())
            .entries
            .fold<List<EventCard>>(
              [],
              (acc, entry) => [
                ...acc,
                ...entry.value.map(
                  (timestamp) => EventCard(entry.key, timestamp),
                ),
              ],
            )
            .sorted(
              (a, b) => (a).timestamp.startDateTime.compareTo(
                (b).timestamp.startDateTime,
              ),
            ),
      ],
    ),
  ),
);
