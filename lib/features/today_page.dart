import 'package:calendorg/core/files/cubit/org_files_cubit.dart';
import 'package:calendorg/features/calendar/event_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Widget todayPage() => BlocBuilder<OrgFilesCubit, OrgFilesState>(
  builder: (context, state) {
    final now = DateTime.now();
    final endDate = now.add(Duration(days: 3));
    final occurrences = state.occurrencesInRange(
      DateTimeRange(start: now, end: endDate),
    );

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
          ...occurrences.map((o) => EventCard(o)),
        ],
      ),
    );
  },
);
