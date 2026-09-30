import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'files/cubit/org_files_cubit.dart';
import 'settings/app_settings.dart';
import 'settings/settings_cubit.dart';

class TodoStatesListener extends BlocListener<SettingsCubit, AppSettings> {
  TodoStatesListener({super.key, super.child})
    : super(
        listenWhen: (previous, current) =>
            previous.todoStates != current.todoStates,
        listener: (context, settings) => unawaited(
          context.read<OrgFilesCubit>().changeTodoStates(settings.todoStates),
        ),
      );
}
