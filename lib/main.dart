import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/files/cubit/org_files_cubit.dart';
import 'core/files/services/org_file_persistence_service.dart';
import 'core/files/services/org_files_repository.dart';
import 'core/files/services/org_parser_service.dart';
import 'core/logging.dart';
import 'core/starting_day_cubit.dart';
import 'core/tag_colors/tag_colors_cubit.dart';
import 'core/todo_states_cubit.dart';
import 'core/todo_states_listener.dart';
import 'features/calendar/ui/calendar_page.dart';
import 'features/diff_view/model/diff_view_cubit.dart';
import 'features/diff_view/ui/diff_view_page.dart';
import 'features/settings/settings_overview/ui/settings_page.dart';
import 'features/settings/theme/model/theme_bloc.dart';
import 'features/today_page/ui/today_page.dart';
import 'l10n/calendorg_localizations.dart';
import 'shared/config/preferences_service.dart';
import 'shared/ui/errors.dart';
import 'theme.dart';
import 'util.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setUpLogging();

  final preferences = PreferencesService();
  final todoStatesCubit = TodoStatesCubit(preferences);
  await todoStatesCubit.loadFromPrefs();
  final parserService = OrgParserService(todoStatesCubit.state);
  await parserService.start();
  final filePicker = FilePickerWritable();
  final repository = OrgFilesRepository(
    filePicker: filePicker,
    persistence: OrgFilePersistenceService(preferences, filePicker),
    parserService: parserService,
  );

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: preferences),
        RepositoryProvider.value(value: repository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => ThemeBloc()),
          BlocProvider.value(value: todoStatesCubit),
          BlocProvider(
            create: (context) =>
                StartingDayCubit(context.read<PreferencesService>())
                  ..setInititalStartingDay(),
          ),
          BlocProvider(
            create: (context) =>
                TagColorsCubit(context.read<PreferencesService>())
                  ..setInitialTagColor(),
          ),
          BlocProvider(
            create: (context) {
              return OrgFilesCubit(context.read<OrgFilesRepository>())
                ..init(context.read<TodoStatesCubit>().state);
            },
          ),
          if (kDebugMode) BlocProvider(create: (context) => DiffViewCubit()),
        ],
        child: const Calendorg(),
      ),
    ),
  );
}

class Calendorg extends StatelessWidget {
  const Calendorg({super.key});

  @override
  Widget build(BuildContext context) {
    return TodoStatesListener(
      child: BlocBuilder<ThemeBloc, ThemeMode>(
        builder: (context, state) {
          return MaterialApp(
            title: 'calendorg',
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: state,
            localizationsDelegates:
                CalendorgLocalizations.localizationsDelegates,
            supportedLocales: CalendorgLocalizations.supportedLocales,
            home: const HomePage(),
          );
        },
      ),
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
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onResume: () => context.read<OrgFilesCubit>().reload(),
    );
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List pages = [
      if (kDebugMode) const DiffViewPage(),
      const TodayPage(),
      CalendarPage(DateTime.now()),
      const SettingsPage(),
    ];
    return BlocConsumer<OrgFilesCubit, OrgFilesState>(
      listenWhen: (_, filesState) => filesState.problem != null,
      listener: (context, filesState) =>
          showProblem(context, filesState.problem!),
      builder: (context, filesState) {
        return Scaffold(
          body: SafeArea(child: pages[index]),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (filesState.status == OrgFilesStatus.loading)
                const LinearProgressIndicator(minHeight: 2),
              NavigationBar(
                onDestinationSelected: (value) => setState(() {
                  index = value;
                }),
                selectedIndex: index,
                destinations: [
                  if (kDebugMode)
                    const NavigationDestination(
                      icon: Icon(Icons.compare_arrows),
                      label: 'Diff',
                    ),
                  NavigationDestination(
                    icon: const Icon(Icons.view_agenda_outlined),
                    selectedIcon: const Icon(Icons.view_agenda),
                    label: context.l10n.nav_agenda,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.calendar_month_outlined),
                    selectedIcon: const Icon(Icons.calendar_month),
                    label: context.l10n.nav_calendar,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.settings_outlined),
                    selectedIcon: const Icon(Icons.settings),
                    label: context.l10n.nav_settings,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
