import '../../date_picker/model/date_picker_bloc.dart';
import '../../date_picker/ui/date_picker.dart';
import '../model/event_view_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:org_parser/org_parser.dart';

void openDatePicker(BuildContext context, OrgTimestamp timestamp) {
  showDialog(
    context: context,
    builder: (_) {
      return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => DatePickerBloc(DatePickerState.initial(timestamp)),
          ),
          BlocProvider.value(value: context.read<EventViewBloc>()),
        ],
        child: DatePicker((timestamp) {
          context.read<EventViewBloc>().add(
            EventViewChangeTimestamp(timestamp),
          );
        }),
      );
    },
  );
}
