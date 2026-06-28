import 'package:calendorg/core/files/cubit/org_files_cubit.dart';
import 'package:calendorg/core/files/services/event_parser_service.dart';
import 'package:calendorg/core/files/services/org_file_persistence_service.dart';
import 'package:calendorg/core/files/services/org_file_service.dart';
import 'package:calendorg/core/files/services/org_files_repository.dart';
import 'package:calendorg/core/files/services/org_parser_service.dart';
import 'package:calendorg/core/floating_action_button_cubit.dart';
import 'package:calendorg/core/tag_colors/tag_colors_cubit.dart';
import 'package:calendorg/core/todo_states_cubit.dart';
import 'package:calendorg/features/calendar/calendar_page.dart';
import 'package:calendorg/features/diff_view/cubit/diff_view_cubit.dart';
import 'package:calendorg/features/diff_view/diff_view_page.dart';
import 'package:calendorg/features/today_page.dart';
import 'package:calendorg/features/settings/settings_page.dart';
import 'package:calendorg/core/starting_day_cubit.dart';
import 'package:calendorg/features/settings/theme/bloc/theme_bloc.dart';
import 'package:calendorg/l10n/calendorg_localizations.dart';
import 'package:calendorg/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final todoStatesCubit = TodoStatesCubit();
  await todoStatesCubit.loadFromPrefs();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ThemeBloc()),
        BlocProvider.value(value: todoStatesCubit),
      ],
      child: const Calendorg(),
    ),
  );
}

class Calendorg extends StatelessWidget {
  const Calendorg({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeMode>(
      builder: (context, state) {
        return MaterialApp(
          title: 'calendorg',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: state,
          localizationsDelegates: CalendorgLocalizations.localizationsDelegates,
          supportedLocales: CalendorgLocalizations.supportedLocales,
          home: MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) =>
                    StartingDayCubit()..setInititalStartingDay(),
              ),
              BlocProvider(
                create: (context) => TagColorsCubit()..setInitialTagColor(),
              ),
              BlocProvider(
                create: (context) {
                  final parserService = OrgParserService(
                    context.read<TodoStatesCubit>().state,
                  );
                  return OrgFilesCubit(
                    OrgFilesRepository(
                      fileService: OrgFileService(parserService),
                      eventParser: EventParserService(),
                      persistence: OrgFilePersistenceService(),
                      parserService: parserService,
                    ),
                  )..init(context.read<TodoStatesCubit>().state);
                },
              ),
              BlocProvider(create: (context) => FloatingActionButtonCubit()),
              if (kDebugMode)
                BlocProvider(create: (context) => DiffViewCubit()),
            ],
            child: HomePage(),
          ),
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final List pages = [
      if (kDebugMode) DiffViewPage(),
      todayPage(),
      CalendarPage(DateTime.now()),
      SettingsPage(),
    ];
    return BlocBuilder<FloatingActionButtonCubit, FloatingActionButton?>(
      builder: (context, buttonState) {
        return BlocBuilder<OrgFilesCubit, OrgFilesState>(
          builder: (context, filesState) {
            switch (filesState.status) {
              case OrgFilesStatus.loading:
                return Scaffold(
                  body: SafeArea(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              case OrgFilesStatus.failure:
                return Scaffold(
                  body: SafeArea(child: Text(filesState.errors.toString())),
                );
              case OrgFilesStatus.success:
                return Scaffold(
                  body: SafeArea(child: pages[index]),
                  bottomNavigationBar: NavigationBar(
                    onDestinationSelected: (value) => setState(() {
                      index = value;
                    }),
                    selectedIndex: index,
                    destinations: [
                      if (kDebugMode)
                        NavigationDestination(
                          icon: Icon(Icons.compare_arrows),
                          label: 'Diff',
                        ),
                      NavigationDestination(
                        icon: Icon(Icons.list),
                        label: 'Events',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.calendar_today),
                        label: 'Calendar',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.settings),
                        label: 'Settings',
                      ),
                    ],
                  ),
                  floatingActionButton: buttonState,
                );
            }
          },
        );
      },
    );
  }
}
