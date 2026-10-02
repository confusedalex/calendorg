// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'calendorg_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class CalendorgLocalizationsEn extends CalendorgLocalizations {
  CalendorgLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get nav_agenda => 'Agenda';

  @override
  String get nav_calendar => 'Calendar';

  @override
  String get nav_settings => 'Settings';

  @override
  String get nav_habits => 'Habits';

  @override
  String get add => 'Add';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get set => 'Set';

  @override
  String get not_set => 'Not set';

  @override
  String validation_empty(String name) {
    return '$name can\'t be empty.';
  }

  @override
  String validation_exists(String name) {
    return '$name already exists.';
  }

  @override
  String get file_could_not_open => 'The file could not be opened.';

  @override
  String get file_already_exists => 'This file is already in the list.';

  @override
  String get select_file => 'Select file';

  @override
  String get create_file => 'Create file';

  @override
  String get agenda_files => 'Agenda files';

  @override
  String get file_name_couldnt_load => 'File name could not be loaded';

  @override
  String get pick_org_directory => 'Pick org directory';

  @override
  String get inbox_file => 'Inbox file';

  @override
  String get error_selecting_file => 'The file could not be selected.';

  @override
  String get error_creating_file => 'The file could not be created.';

  @override
  String get error_loading_file => 'The file could not be loaded.';

  @override
  String get error_saving_section => 'The change could not be saved.';

  @override
  String get error_reading_file => 'The file could not be read.';

  @override
  String get error_file_not_in_org_folder =>
      'This file is not in your org folder. Choose a file from the org folder, or change the org folder.';

  @override
  String error_entry_not_found(String title) {
    return '\"$title\" is no longer in the file.';
  }

  @override
  String get error_file_changed_on_disk =>
      'File changed on disk. The app reloaded it. Please try the edit again.';

  @override
  String error_files_not_found(int count, String names) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count files not found: $names',
      one: '1 file not found: $names',
    );
    return '$_temp0';
  }

  @override
  String get error_edit_before_loading =>
      'Wait until the files are loaded, then try again.';

  @override
  String get error_inbox_file_to_agenda_files =>
      'The inbox file can\'t also be an agenda file.';

  @override
  String get error_already_in_agenda_files =>
      'This file is already an agenda file.';

  @override
  String get error_unknown =>
      'The files could not be loaded. Pull down to try again.';

  @override
  String get tag_colors => 'Tag colors';

  @override
  String get add_new_tag => 'Add tag';

  @override
  String get tag_name => 'Tag name';

  @override
  String edit_tag(String tag) {
    return 'Edit tag \"$tag\"';
  }

  @override
  String get starting_day => 'Starting day';

  @override
  String get starting_day_of_week => 'Starting day of the week';

  @override
  String get monday => 'Monday';

  @override
  String get sunday => 'Sunday';

  @override
  String get theme => 'Theme';

  @override
  String get choose_theme => 'Choose theme';

  @override
  String get theme_dark => 'Dark';

  @override
  String get theme_light => 'Light';

  @override
  String get theme_automatic => 'Automatic';

  @override
  String get todo_states => 'TODO states';

  @override
  String get todo_state => 'TODO state';

  @override
  String get todo_state_name => 'TODO state name';

  @override
  String get todo_status_todo => 'Todo';

  @override
  String get todo_status_done => 'Done';

  @override
  String get todo_status_ignored => 'Ignored';

  @override
  String get debug => 'Debug';

  @override
  String get edit_event => 'Edit event';

  @override
  String get add_event => 'Add event';

  @override
  String get event_title => 'Event title';

  @override
  String get heading_title => 'Heading title';

  @override
  String get title => 'Title';

  @override
  String get when => 'When';

  @override
  String get need_inbox_file => 'Set an inbox file in Settings first.';

  @override
  String get select_date => 'Select date';

  @override
  String get start_date => 'Start date';

  @override
  String get start_time => 'Start time';

  @override
  String get end_date => 'End date';

  @override
  String get end_time => 'End time';

  @override
  String get select_end_date => 'Select end date';

  @override
  String get error_end_time_before_start =>
      'The end time is before the start time.';

  @override
  String get copy_log => 'Copy log';

  @override
  String get log_copied => 'Log copied to the clipboard';

  @override
  String get today => 'Today';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get no_events => 'No events';

  @override
  String no_upcoming_events(int count) {
    return 'Nothing planned for the next $count days';
  }

  @override
  String get settings_section_files => 'Files';

  @override
  String get settings_section_calendar => 'Calendar';

  @override
  String get settings_section_appearance => 'Appearance';

  @override
  String get settings_section_diagnostics => 'Diagnostics';

  @override
  String next_days(int count) {
    return 'Next $count days';
  }

  @override
  String get setup_hint =>
      'Choose your org folder and files to see your events.';

  @override
  String get choose_files => 'Choose files';

  @override
  String get intro_welcome_title => 'Welcome to calendorg';

  @override
  String get intro_welcome_body =>
      'Calendorg is a companion app for Emacs org-mode.\n\nIt shows your org files as a calendar. You can change headings and timestamps, and quickly add new events to an inbox file.\n\nIt is not a full org-mode viewer or task manager.';

  @override
  String get intro_directory_title => 'Pick your org directory';

  @override
  String get intro_directory_body =>
      'Pick the folder where your org files are.\n\nIf you do not have one yet, create one and come back later.';

  @override
  String get intro_files_title => 'Select your agenda files';

  @override
  String get intro_files_body =>
      'Choose the files that you want to see in the calendar.';

  @override
  String get intro_inbox_title => 'Inbox file';

  @override
  String get intro_inbox_body =>
      'New events that you create in the app go into your inbox file.\n\nYou can skip this step and choose a file later.';

  @override
  String get intro_tags_title => 'Give your tags colors';

  @override
  String get intro_tags_body =>
      'Give each tag a color to tell your events apart.\n\nIf an event has more than one tag, the first tag in the list sets its color. You can change the order in the settings.';

  @override
  String get intro_add_tag => 'Add tag';

  @override
  String get intro_next => 'Continue';

  @override
  String get intro_skip => 'Skip';

  @override
  String get intro_finish => 'Finish Setup';

  @override
  String get habits => 'Habits';

  @override
  String habit_every(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Every $count days',
      one: 'Every day',
    );
    return '$_temp0';
  }

  @override
  String habit_every_range(int min, int max) {
    return 'Every $min to $max days';
  }

  @override
  String habit_streak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count in a row',
      zero: 'No streak',
    );
    return '$_temp0';
  }

  @override
  String get habit_mark_done => 'Mark as done today';

  @override
  String get habit_done_today => 'Done today';

  @override
  String get habit_status_early => 'Not due';

  @override
  String get habit_status_due => 'Due';

  @override
  String get habit_status_last_day => 'Last day';

  @override
  String get habit_status_overdue => 'Overdue';

  @override
  String get settings_show_habits => 'Habits tab';

  @override
  String get settings_show_habits_hint =>
      'Shows entries with the property STYLE: habit';
}
