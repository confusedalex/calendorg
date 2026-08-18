import 'package:calendorg/features/date_picker/model/date_picker_bloc.dart';
import 'package:calendorg/features/date_picker/ui/date_picker.dart';
import 'package:calendorg/features/new_section/model/new_section_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void openDatePicker(BuildContext context, DateTime initialDateTime) {
  showDialog(
    context: context,
    builder: (_) {
      return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => DatePickerBloc(
              DatePickerState.parseDateTimeWithoutTime(initialDateTime),
            ),
          ),
        ],
        child: DatePicker((timestamp) {
          context.read<NewSectionCubit>().changeTimestamp(timestamp);
        }),
      );
    },
  );
}
