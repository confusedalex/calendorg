import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/files/cubit/org_files_cubit.dart';
import 'core/files/services/org_file_persistence_service.dart';
import 'core/files/services/org_file_service.dart';
import 'core/files/services/org_files_repository.dart';
import 'core/files/services/org_parser_service.dart';
import 'core/floating_action_button_cubit.dart';
import 'core/starting_day_cubit.dart';
import 'core/tag_colors/tag_colors_cubit.dart';
import 'core/todo_states_cubit.dart';
import 'entities/org_entry/event_parser_service.dart';
import 'features/calendar/ui/calendar_page.dart';
import 'features/diff_view/model/diff_view_cubit.dart';
import 'features/diff_view/ui/diff_view_page.dart';
import 'features/settings/settings_overview/ui/settings_page.dart';
import 'features/settings/theme/model/theme_bloc.dart';
import 'features/today_page/ui/today_page.dart';
import 'l10n/calendorg_localizations.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final todoStatesCubit = TodoStatesCubit();
  await todoStatesCubit.loadFromPrefs();
  final parserService = OrgParserService(todoStatesCubit.state);
  await parserService.start();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ThemeBloc()),
        BlocProvider.value(value: todoStatesCubit),
      ],
      child: Calendorg(parserService: parserService),
    ),
  );
}

class Calendorg extends StatelessWidget {
  final OrgParserService parserService;

  const Calendorg({super.key, required this.parserService});

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
                  return OrgFilesCubit(
                    OrgFilesRepository(
                      fileService: OrgFileService(parserService),
                      persistence: OrgFilePersistenceService(),
                      parserService: parserService,
                      eventParserService: EventParserService(),
                    ),
                  )..init(context.read<TodoStatesCubit>().state);
                },
              ),
              BlocProvider(create: (context) => FloatingActionButtonCubit()),
              if (kDebugMode)
                BlocProvider(create: (context) => DiffViewCubit()),
            ],
            child: const HomePage(),
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
  var index = 0;

  @override
  Widget build(BuildContext context) {
    final List pages = [
      if (kDebugMode) const DiffViewPage(),
      todayPage(),
      CalendarPage(DateTime.now()),
      const SettingsPage(),
    ];
    return BlocBuilder<FloatingActionButtonCubit, Function?>(
      builder: (context, actionButtonCallback) {
        return BlocBuilder<OrgFilesCubit, OrgFilesState>(
          builder: (context, filesState) {
            return Stack(
              children: [
                Scaffold(
                  body: SafeArea(child: pages[index]),
                  bottomNavigationBar: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (filesState.status == OrgFilesStatus.loading)
                        const LinearProgressIndicator(),
                      NavigationBar(
                        onDestinationSelected: (value) => setState(() {
                          index = value;
                        }),
                        selectedIndex: index,
                        destinations: const [
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
                    ],
                  ),
                  floatingActionButton: actionButtonCallback != null
                      ? FloatingActionButton(onPressed: actionButtonCallback())
                      : null,
                ),
              ],
            );
          },
        );
      },
    );
  }
}
