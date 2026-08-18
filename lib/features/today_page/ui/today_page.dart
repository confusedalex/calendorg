import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/files/cubit/org_files_cubit.dart';
import '../../calendar/ui/event_card.dart';

Widget todayPage() => BlocBuilder<OrgFilesCubit, OrgFilesState>(
  builder: (context, state) {
    final now = DateTime.now();
    final endDate = now.add(const Duration(days: 3));
    final occurrences = state.occurrencesInRange(
      DateTimeRange(start: now, end: endDate),
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Next 3 days',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          ...occurrences.map(EventCard.new),
        ],
      ),
    );
  },
);
