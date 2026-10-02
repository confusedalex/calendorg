import 'dart:async';

import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/files/cubit/org_files_cubit.dart';
import 'core/files/services/org_file_persistence_service.dart';
import 'core/files/services/org_files_repository.dart';
import 'core/files/services/org_parser_service.dart';
import 'core/logging.dart';
import 'core/settings/app_settings.dart';
import 'core/settings/settings_cubit.dart';
import 'core/todo_states_listener.dart';
import 'entities/org_entry/org_entry.dart';
import 'features/calendar/ui/calendar_page.dart';
import 'features/diff_view/model/diff_view_cubit.dart';
import 'features/diff_view/ui/diff_view_page.dart';
import 'features/habits/ui/habits_page.dart';
import 'features/settings/settings_overview/ui/settings_page.dart';
import 'features/today_page/ui/today_page.dart';
import 'l10n/calendorg_localizations.dart';
import 'pages/introduction_screen/ui/calendorg_introduction.dart';
import 'shared/config/preferences_service.dart';
import 'shared/ui/errors.dart';
import 'theme.dart';
import 'util.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setUpLogging();

  final preferences = PreferencesService();
  final settingsCubit = await SettingsCubit.load(preferences);
  final showSetup = await preferences.getBool(PrefKeys.showSetup) ?? true;
  final parserService = await OrgParserService.spawn(
    settingsCubit.state.todoStates,
  );
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
          BlocProvider.value(value: settingsCubit),
          BlocProvider(
            create: (context) {
              return OrgFilesCubit(context.read<OrgFilesRepository>())
                ..init(context.read<SettingsCubit>().state.todoStates);
            },
          ),
          if (kDebugMode) BlocProvider(create: (context) => DiffViewCubit()),
        ],
        child: Calendorg(showSetup: showSetup),
      ),
    ),
  );
}

class Calendorg extends StatelessWidget {
  const Calendorg({required this.showSetup, super.key});

  final bool showSetup;

  @override
  Widget build(BuildContext context) {
    return TodoStatesListener(
      child: BlocSelector<SettingsCubit, AppSettings, ThemeMode>(
        selector: (settings) => settings.themeMode,
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'calendorg',
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeMode,
            localizationsDelegates:
                CalendorgLocalizations.localizationsDelegates,
            supportedLocales: CalendorgLocalizations.supportedLocales,
            home: HomePage(showSetup: showSetup),
          );
        },
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    this.showDebugTab = kDebugMode,
    this.showSetup = false,
  });

  final bool showDebugTab;
  final bool showSetup;

  @override
  State<HomePage> createState() => _HomePageState();
}

enum _Tab { diff, agenda, calendar, habits, settings }

class _HomePageState extends State<HomePage> {
  var _tab = _Tab.agenda;
  late var _showSetup = widget.showSetup;
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onResume: () => context.read<OrgFilesCubit>().reload(),
    );
  }

  Future<void> _finishSetup() async {
    setState(() => _showSetup = false);
    await context.read<PreferencesService>().setBool(
      PrefKeys.showSetup,
      value: false,
    );
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showSetup) {
      return IntroductionPage(onDone: () => unawaited(_finishSetup()));
    }

    final showHabits =
        context.select((SettingsCubit cubit) => cubit.state.showHabits) &&
        context.select(
          (OrgFilesCubit cubit) =>
              cubit.state.entries.any((e) => e is OrgHabit),
        );
    final tabs = [
      if (widget.showDebugTab) _Tab.diff,
      _Tab.agenda,
      _Tab.calendar,
      if (showHabits) _Tab.habits,
      _Tab.settings,
    ];
    final tab = tabs.contains(_tab) ? _tab : _Tab.agenda;

    return BlocConsumer<OrgFilesCubit, OrgFilesState>(
      listenWhen: (_, filesState) => filesState.problem != null,
      listener: (context, filesState) =>
          showProblem(context, filesState.problem!),
      builder: (context, filesState) {
        return Scaffold(
          body: SafeArea(
            child: switch (tab) {
              _Tab.diff => const DiffViewPage(),
              _Tab.agenda => const TodayPage(),
              _Tab.calendar => CalendarPage(DateTime.now()),
              _Tab.habits => const HabitsPage(),
              _Tab.settings => const SettingsPage(),
            },
          ),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (filesState.status == OrgFilesStatus.loading)
                const LinearProgressIndicator(minHeight: 2),
              NavigationBar(
                onDestinationSelected: (value) => setState(() {
                  _tab = tabs[value];
                }),
                selectedIndex: tabs.indexOf(tab),
                destinations: [
                  for (final tab in tabs)
                    switch (tab) {
                      _Tab.diff => const NavigationDestination(
                        icon: Icon(Icons.compare_arrows),
                        label: 'Diff',
                      ),
                      _Tab.agenda => NavigationDestination(
                        icon: const Icon(Icons.view_agenda_outlined),
                        selectedIcon: const Icon(Icons.view_agenda),
                        label: context.l10n.nav_agenda,
                      ),
                      _Tab.calendar => NavigationDestination(
                        icon: const Icon(Icons.calendar_month_outlined),
                        selectedIcon: const Icon(Icons.calendar_month),
                        label: context.l10n.nav_calendar,
                      ),
                      _Tab.habits => NavigationDestination(
                        icon: const Icon(Icons.task_alt_outlined),
                        selectedIcon: const Icon(Icons.task_alt),
                        label: context.l10n.nav_habits,
                      ),
                      _Tab.settings => NavigationDestination(
                        icon: const Icon(Icons.settings_outlined),
                        selectedIcon: const Icon(Icons.settings),
                        label: context.l10n.nav_settings,
                      ),
                    },
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
