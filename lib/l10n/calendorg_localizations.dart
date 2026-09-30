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
  /// **'{name} can\'t be empty!'**
  String validation_empty(String name);

  /// No description provided for @validation_exists.
  ///
  /// In en, this message translates to:
  /// **'{name} already exists!'**
  String validation_exists(String name);

  /// No description provided for @file_could_not_open.
  ///
  /// In en, this message translates to:
  /// **'File could not be opened!'**
  String get file_could_not_open;

  /// No description provided for @file_already_exists.
  ///
  /// In en, this message translates to:
  /// **'File already exists!'**
  String get file_already_exists;

  /// No description provided for @select_file.
  ///
  /// In en, this message translates to:
  /// **'select file'**
  String get select_file;

  /// No description provided for @create_file.
  ///
  /// In en, this message translates to:
  /// **'create file'**
  String get create_file;

  /// No description provided for @agenda_files.
  ///
  /// In en, this message translates to:
  /// **'Agenda Files'**
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
  /// **'Inbox File'**
  String get inbox_file;

  /// No description provided for @error_selecting_file.
  ///
  /// In en, this message translates to:
  /// **'Error selecting file: {error}'**
  String error_selecting_file(Object error);

  /// No description provided for @error_creating_file.
  ///
  /// In en, this message translates to:
  /// **'Error creating file: {error}'**
  String error_creating_file(Object error);

  /// No description provided for @error_loading_file.
  ///
  /// In en, this message translates to:
  /// **'Error loading file: {error}'**
  String error_loading_file(Object error);

  /// No description provided for @error_saving_section.
  ///
  /// In en, this message translates to:
  /// **'Error saving section: {error}'**
  String error_saving_section(Object error);

  /// No description provided for @error_reading_file.
  ///
  /// In en, this message translates to:
  /// **'Error while reading file!'**
  String get error_reading_file;

  /// No description provided for @error_file_not_in_org_folder.
  ///
  /// In en, this message translates to:
  /// **'File is not in org folder!\nPlease select a file that lies in your org folder or change your org folder.'**
  String get error_file_not_in_org_folder;

  /// No description provided for @error_entry_not_found.
  ///
  /// In en, this message translates to:
  /// **'Entry {title} no longer found in file!'**
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
  /// **'Can\'t edit heading before loading!'**
  String get error_edit_before_loading;

  /// No description provided for @error_inbox_file_to_agenda_files.
  ///
  /// In en, this message translates to:
  /// **'Inbox file can\'t be added to agenda files.'**
  String get error_inbox_file_to_agenda_files;

  /// No description provided for @error_already_in_agenda_files.
  ///
  /// In en, this message translates to:
  /// **'File already in agenda files.'**
  String get error_already_in_agenda_files;

  /// No description provided for @error_unknown.
  ///
  /// In en, this message translates to:
  /// **'Some error has occurred!'**
  String get error_unknown;

  /// No description provided for @tag_colors.
  ///
  /// In en, this message translates to:
  /// **'Tag Colors'**
  String get tag_colors;

  /// No description provided for @tag_color.
  ///
  /// In en, this message translates to:
  /// **'Tag Color'**
  String get tag_color;

  /// No description provided for @add_new_tag.
  ///
  /// In en, this message translates to:
  /// **'Add new Tag'**
  String get add_new_tag;

  /// No description provided for @tag_name.
  ///
  /// In en, this message translates to:
  /// **'Tag name'**
  String get tag_name;

  /// No description provided for @edit_tag.
  ///
  /// In en, this message translates to:
  /// **'Edit \"{tag}\" Tag'**
  String edit_tag(String tag);

  /// No description provided for @starting_day.
  ///
  /// In en, this message translates to:
  /// **'Starting Day'**
  String get starting_day;

  /// No description provided for @starting_day_of_week.
  ///
  /// In en, this message translates to:
  /// **'Starting Day of Week'**
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
  /// **'Choose Theme'**
  String get choose_theme;

  /// No description provided for @theme_dark.
  ///
  /// In en, this message translates to:
  /// **'dark'**
  String get theme_dark;

  /// No description provided for @theme_light.
  ///
  /// In en, this message translates to:
  /// **'light'**
  String get theme_light;

  /// No description provided for @theme_automatic.
  ///
  /// In en, this message translates to:
  /// **'automatic'**
  String get theme_automatic;

  /// No description provided for @todo_states.
  ///
  /// In en, this message translates to:
  /// **'TODO States'**
  String get todo_states;

  /// No description provided for @todo_state.
  ///
  /// In en, this message translates to:
  /// **'TODO State'**
  String get todo_state;

  /// No description provided for @todo_state_name.
  ///
  /// In en, this message translates to:
  /// **'TODO State Name'**
  String get todo_state_name;

  /// No description provided for @todo_status_todo.
  ///
  /// In en, this message translates to:
  /// **'todo'**
  String get todo_status_todo;

  /// No description provided for @todo_status_done.
  ///
  /// In en, this message translates to:
  /// **'done'**
  String get todo_status_done;

  /// No description provided for @todo_status_ignored.
  ///
  /// In en, this message translates to:
  /// **'ignored'**
  String get todo_status_ignored;

  /// No description provided for @debug.
  ///
  /// In en, this message translates to:
  /// **'Debug'**
  String get debug;

  /// No description provided for @edit_event.
  ///
  /// In en, this message translates to:
  /// **'Edit Event'**
  String get edit_event;

  /// No description provided for @add_event.
  ///
  /// In en, this message translates to:
  /// **'Add Event'**
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

  /// No description provided for @change_date_and_time.
  ///
  /// In en, this message translates to:
  /// **'Change date and time'**
  String get change_date_and_time;

  /// No description provided for @need_inbox_file.
  ///
  /// In en, this message translates to:
  /// **'You need to set an inbox file'**
  String get need_inbox_file;

  /// No description provided for @select_date.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get select_date;

  /// No description provided for @start_date.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get start_date;

  /// No description provided for @start_time.
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get start_time;

  /// No description provided for @end_date.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get end_date;

  /// No description provided for @end_time.
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get end_time;

  /// No description provided for @select_end_date.
  ///
  /// In en, this message translates to:
  /// **'select end date'**
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
