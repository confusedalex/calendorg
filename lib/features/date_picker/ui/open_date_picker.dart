import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:org_parser/org_parser.dart';

import '../model/date_picker_bloc.dart';
import 'date_picker.dart';

Future<void> openDatePicker(
  BuildContext context,
  DatePickerState initialState,
  void Function(OrgTimestamp timestamp) onChanged,
) => showDialog(
  context: context,
  builder: (_) {
    return BlocProvider(
      create: (_) => DatePickerBloc(initialState),
      child: DatePicker(onChanged),
    );
  },
);
