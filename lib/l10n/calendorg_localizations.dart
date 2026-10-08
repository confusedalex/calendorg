import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'calendorg_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of CalendorgLocalizations
/// returned by `CalendorgLocalizations.of(context)`.
///
/// Applications need to include `CalendorgLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/calendorg_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: CalendorgLocalizations.localizationsDelegates,
///   supportedLocales: CalendorgLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the CalendorgLocalizations.supportedLocales
/// property.
abstract class CalendorgLocalizations {
  CalendorgLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static CalendorgLocalizations of(BuildContext context) {
    return Localizations.of<CalendorgLocalizations>(
      context,
      CalendorgLocalizations,
    )!;
  }

  static const LocalizationsDelegate<CalendorgLocalizations> delegate =
      _CalendorgLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @nav_agenda.
  ///
  /// In en, this message translates to:
  /// **'Agenda'**
  String get nav_agenda;

  /// No description provided for @nav_calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get nav_calendar;

  /// No description provided for @nav_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get nav_settings;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @set.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get set;

  /// No description provided for @not_set.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get not_set;

  /// No description provided for @validation_empty.
  ///
  /// In en, this message translates to:
  /// **'{name} can\'t be empty.'**
  String validation_empty(String name);

  /// No description provided for @validation_exists.
  ///
  /// In en, this message translates to:
  /// **'{name} already exists.'**
  String validation_exists(String name);

  /// No description provided for @file_could_not_open.
  ///
  /// In en, this message translates to:
  /// **'The file could not be opened.'**
  String get file_could_not_open;

  /// No description provided for @file_already_exists.
  ///
  /// In en, this message translates to:
  /// **'This file is already in the list.'**
  String get file_already_exists;

  /// No description provided for @select_file.
  ///
  /// In en, this message translates to:
  /// **'Select file'**
  String get select_file;

  /// No description provided for @agenda_files.
  ///
  /// In en, this message translates to:
  /// **'Agenda files'**
  String get agenda_files;

  /// No description provided for @file_name_couldnt_load.
  ///
  /// In en, this message translates to:
  /// **'File name could not be loaded'**
  String get file_name_couldnt_load;

  /// No description provided for @pick_org_directory.
  ///
  /// In en, this message translates to:
  /// **'Pick org directory'**
  String get pick_org_directory;

  /// No description provided for @inbox_file.
  ///
  /// In en, this message translates to:
  /// **'Inbox file'**
  String get inbox_file;

  /// No description provided for @error_selecting_file.
  ///
  /// In en, this message translates to:
  /// **'The file could not be selected.'**
  String get error_selecting_file;

  /// No description provided for @error_creating_file.
  ///
  /// In en, this message translates to:
  /// **'The file could not be created.'**
  String get error_creating_file;

  /// No description provided for @error_loading_file.
  ///
  /// In en, this message translates to:
  /// **'The file could not be loaded.'**
  String get error_loading_file;

  /// No description provided for @error_saving_section.
  ///
  /// In en, this message translates to:
  /// **'The change could not be saved.'**
  String get error_saving_section;

  /// No description provided for @error_reading_file.
  ///
  /// In en, this message translates to:
  /// **'The file could not be read.'**
  String get error_reading_file;

  /// No description provided for @error_file_not_in_org_folder.
  ///
  /// In en, this message translates to:
  /// **'This file is not in your org folder. Choose a file from the org folder, or change the org folder.'**
  String get error_file_not_in_org_folder;

  /// No description provided for @error_entry_not_found.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" is no longer in the file.'**
  String error_entry_not_found(String title);

  /// No description provided for @error_file_changed_on_disk.
  ///
  /// In en, this message translates to:
  /// **'File changed on disk. The app reloaded it. Please try the edit again.'**
  String get error_file_changed_on_disk;

  /// No description provided for @error_files_not_found.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 file not found: {names}} other{{count} files not found: {names}}}'**
  String error_files_not_found(int count, String names);

  /// No description provided for @error_edit_before_loading.
  ///
  /// In en, this message translates to:
  /// **'Wait until the files are loaded, then try again.'**
  String get error_edit_before_loading;

  /// No description provided for @error_inbox_file_to_agenda_files.
  ///
  /// In en, this message translates to:
  /// **'The inbox file can\'t also be an agenda file.'**
  String get error_inbox_file_to_agenda_files;

  /// No description provided for @error_already_in_agenda_files.
  ///
  /// In en, this message translates to:
  /// **'This file is already an agenda file.'**
  String get error_already_in_agenda_files;

  /// No description provided for @error_unknown.
  ///
  /// In en, this message translates to:
  /// **'The files could not be loaded. Pull down to try again.'**
  String get error_unknown;

  /// No description provided for @tag_colors.
  ///
  /// In en, this message translates to:
  /// **'Tag colors'**
  String get tag_colors;

  /// No description provided for @add_new_tag.
  ///
  /// In en, this message translates to:
  /// **'Add tag'**
  String get add_new_tag;

  /// No description provided for @tag_name.
  ///
  /// In en, this message translates to:
  /// **'Tag name'**
  String get tag_name;

  /// No description provided for @edit_tag.
  ///
  /// In en, this message translates to:
  /// **'Edit tag \"{tag}\"'**
  String edit_tag(String tag);

  /// No description provided for @starting_day.
  ///
  /// In en, this message translates to:
  /// **'Starting day'**
  String get starting_day;

  /// No description provided for @starting_day_of_week.
  ///
  /// In en, this message translates to:
  /// **'Starting day of the week'**
  String get starting_day_of_week;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @choose_theme.
  ///
  /// In en, this message translates to:
  /// **'Choose theme'**
  String get choose_theme;

  /// No description provided for @theme_dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get theme_dark;

  /// No description provided for @theme_light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get theme_light;

  /// No description provided for @theme_automatic.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get theme_automatic;

  /// No description provided for @todo_states.
  ///
  /// In en, this message translates to:
  /// **'TODO states'**
  String get todo_states;

  /// No description provided for @todo_state.
  ///
  /// In en, this message translates to:
  /// **'TODO state'**
  String get todo_state;

  /// No description provided for @todo_state_name.
  ///
  /// In en, this message translates to:
  /// **'TODO state name'**
  String get todo_state_name;

  /// No description provided for @todo_status_todo.
  ///
  /// In en, this message translates to:
  /// **'Todo'**
  String get todo_status_todo;

  /// No description provided for @todo_status_done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get todo_status_done;

  /// No description provided for @todo_status_ignored.
  ///
  /// In en, this message translates to:
  /// **'Ignored'**
  String get todo_status_ignored;

  /// No description provided for @debug.
  ///
  /// In en, this message translates to:
  /// **'Debug'**
  String get debug;

  /// No description provided for @edit_event.
  ///
  /// In en, this message translates to:
  /// **'Edit event'**
  String get edit_event;

  /// No description provided for @add_event.
  ///
  /// In en, this message translates to:
  /// **'Add event'**
  String get add_event;

  /// No description provided for @event_title.
  ///
  /// In en, this message translates to:
  /// **'Event title'**
  String get event_title;

  /// No description provided for @heading_title.
  ///
  /// In en, this message translates to:
  /// **'Heading title'**
  String get heading_title;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @when.
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get when;

  /// No description provided for @need_inbox_file.
  ///
  /// In en, this message translates to:
  /// **'Set an inbox file in Settings first.'**
  String get need_inbox_file;

  /// No description provided for @select_date.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get select_date;

  /// No description provided for @start_date.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get start_date;

  /// No description provided for @start_time.
  ///
  /// In en, this message translates to:
  /// **'Start time'**
  String get start_time;

  /// No description provided for @end_date.
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get end_date;

  /// No description provided for @end_time.
  ///
  /// In en, this message translates to:
  /// **'End time'**
  String get end_time;

  /// No description provided for @select_end_date.
  ///
  /// In en, this message translates to:
  /// **'Select end date'**
  String get select_end_date;

  /// No description provided for @error_end_time_before_start.
  ///
  /// In en, this message translates to:
  /// **'The end time is before the start time.'**
  String get error_end_time_before_start;

  /// No description provided for @copy_log.
  ///
  /// In en, this message translates to:
  /// **'Copy log'**
  String get copy_log;

  /// No description provided for @log_copied.
  ///
  /// In en, this message translates to:
  /// **'Log copied to the clipboard'**
  String get log_copied;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @no_events.
  ///
  /// In en, this message translates to:
  /// **'No events'**
  String get no_events;

  /// No description provided for @no_upcoming_events.
  ///
  /// In en, this message translates to:
  /// **'Nothing planned for the next {count} days'**
  String no_upcoming_events(int count);

  /// No description provided for @settings_section_files.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get settings_section_files;

  /// No description provided for @settings_section_calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get settings_section_calendar;

  /// No description provided for @settings_section_appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settings_section_appearance;

  /// No description provided for @settings_section_diagnostics.
  ///
  /// In en, this message translates to:
  /// **'Diagnostics'**
  String get settings_section_diagnostics;

  /// No description provided for @next_days.
  ///
  /// In en, this message translates to:
  /// **'Next {count} days'**
  String next_days(int count);

  /// No description provided for @setup_hint.
  ///
  /// In en, this message translates to:
  /// **'Choose your org folder and files to see your events.'**
  String get setup_hint;

  /// No description provided for @choose_files.
  ///
  /// In en, this message translates to:
  /// **'Choose files'**
  String get choose_files;

  /// No description provided for @intro_welcome_title.
  ///
  /// In en, this message translates to:
  /// **'Welcome to calendorg'**
  String get intro_welcome_title;

  /// No description provided for @intro_welcome_body.
  ///
  /// In en, this message translates to:
  /// **'Calendorg is a companion app for Emacs org-mode.\n\nIt shows your org files as a calendar. You can change headings and timestamps, and quickly add new events to an inbox file.\n\nIt is not a full org-mode viewer or task manager.'**
  String get intro_welcome_body;

  /// No description provided for @intro_directory_title.
  ///
  /// In en, this message translates to:
  /// **'Pick your org directory'**
  String get intro_directory_title;

  /// No description provided for @intro_directory_body.
  ///
  /// In en, this message translates to:
  /// **'Pick the folder where your org files are.\n\nIf you do not have one yet, create one and come back later.'**
  String get intro_directory_body;

  /// No description provided for @intro_files_title.
  ///
  /// In en, this message translates to:
  /// **'Select your agenda files'**
  String get intro_files_title;

  /// No description provided for @intro_files_body.
  ///
  /// In en, this message translates to:
  /// **'Choose the files that you want to see in the calendar.'**
  String get intro_files_body;

  /// No description provided for @intro_inbox_title.
  ///
  /// In en, this message translates to:
  /// **'Inbox file'**
  String get intro_inbox_title;

  /// No description provided for @intro_inbox_body.
  ///
  /// In en, this message translates to:
  /// **'New events that you create in the app go into your inbox file.\n\nYou can skip this step and choose a file later.'**
  String get intro_inbox_body;

  /// No description provided for @intro_tags_title.
  ///
  /// In en, this message translates to:
  /// **'Give your tags colors'**
  String get intro_tags_title;

  /// No description provided for @intro_tags_body.
  ///
  /// In en, this message translates to:
  /// **'Give each tag a color to tell your events apart.\n\nIf an event has more than one tag, the first tag in the list sets its color. You can change the order in the settings.'**
  String get intro_tags_body;

  /// No description provided for @intro_add_tag.
  ///
  /// In en, this message translates to:
  /// **'Add tag'**
  String get intro_add_tag;

  /// No description provided for @intro_next.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get intro_next;

  /// No description provided for @intro_skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get intro_skip;

  /// No description provided for @intro_finish.
  ///
  /// In en, this message translates to:
  /// **'Finish Setup'**
  String get intro_finish;
}

class _CalendorgLocalizationsDelegate
    extends LocalizationsDelegate<CalendorgLocalizations> {
  const _CalendorgLocalizationsDelegate();

  @override
  Future<CalendorgLocalizations> load(Locale locale) {
    return SynchronousFuture<CalendorgLocalizations>(
      lookupCalendorgLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_CalendorgLocalizationsDelegate old) => false;
}

CalendorgLocalizations lookupCalendorgLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return CalendorgLocalizationsEn();
  }

  throw FlutterError(
    'CalendorgLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
