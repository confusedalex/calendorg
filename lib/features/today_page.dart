import 'package:calendorg/core/files/cubit/org_files_cubit.dart';
import 'package:calendorg/event.dart';
import 'package:calendorg/features/calendar/event_card.dart';
import 'package:calendorg/util.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:org_parser/org_parser.dart';

Widget todayPage() => BlocBuilder<OrgFilesCubit, OrgFilesState>(
  builder: (context, state) {
    final now = DateTime.now();
    final endDate = now.add(Duration(days: 3));

    final events = dateRange(now, endDate)
        .fold(
          <Event, List<OrgTimestamp>>{},
          (acc, cur) => {...acc, ...state.eventsByDateWithTimestamps(cur)},
        )
        .entries
        .expand(
          (entry) =>
              entry.value.map((timestamp) => EventCard(entry.key, timestamp)),
        )
        .sorted(
          (a, b) =>
              a.timestamp.startDateTime.compareTo(b.timestamp.startDateTime),
        )
        .toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Next 3 days",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          ...events,
        ],
      ),
    );
  },
);
