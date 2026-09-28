// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'calendorg_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class CalendorgLocalizationsEn extends CalendorgLocalizations {
  CalendorgLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get nav_events => 'Events';

  @override
  String get nav_calendar => 'Calendar';

  @override
  String get nav_settings => 'Settings';

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
    return '$name can\'t be empty!';
  }

  @override
  String validation_exists(String name) {
    return '$name already exists!';
  }

  @override
  String get file_could_not_open => 'File could not be opened!';

  @override
  String get file_already_exists => 'File already exists!';

  @override
  String get select_file => 'select file';

  @override
  String get create_file => 'create file';

  @override
  String get agenda_files => 'Agenda Files';

  @override
  String get file_name_couldnt_load => 'File name could not be loaded';

  @override
  String get pick_org_directory => 'Pick org directory';

  @override
  String get inbox_file => 'Inbox File';

  @override
  String error_selecting_file(Object error) {
    return 'Error selecting file: $error';
  }

  @override
  String error_creating_file(Object error) {
    return 'Error creating file: $error';
  }

  @override
  String error_loading_file(Object error) {
    return 'Error loading file: $error';
  }

  @override
  String error_saving_section(Object error) {
    return 'Error saving section: $error';
  }

  @override
  String get error_reading_file => 'Error while reading file!';

  @override
  String get error_file_not_in_org_folder =>
      'File is not in org folder!\nPlease select a file that lies in your org folder or change your org folder.';

  @override
  String error_entry_not_found(Object entry) {
    return 'Entry $entry no longer found in file!';
  }

  @override
  String get error_file_changed_on_disk => 'File changed on disk!';

  @override
  String get error_edit_before_loading => 'Can\'t edit heading before loading!';

  @override
  String get error_unknown => 'Some error has occurred!';

  @override
  String get tag_colors => 'Tag Colors';

  @override
  String get tag_color => 'Tag Color';

  @override
  String get add_new_tag => 'Add new Tag';

  @override
  String edit_tag(String tag) {
    return 'Edit \"$tag\" Tag';
  }

  @override
  String get starting_day => 'Starting Day';

  @override
  String get starting_day_of_week => 'Starting Day of Week';

  @override
  String get monday => 'Monday';

  @override
  String get sunday => 'Sunday';

  @override
  String get weekday_short_monday => 'Mon';

  @override
  String get weekday_short_tuesday => 'Tue';

  @override
  String get weekday_short_wednesday => 'Wed';

  @override
  String get weekday_short_thursday => 'Thu';

  @override
  String get weekday_short_friday => 'Fri';

  @override
  String get weekday_short_saturday => 'Sat';

  @override
  String get weekday_short_sunday => 'Sun';

  @override
  String get theme => 'Theme';

  @override
  String get choose_theme => 'Choose Theme';

  @override
  String get theme_dark => 'dark';

  @override
  String get theme_light => 'light';

  @override
  String get theme_automatic => 'automatic';

  @override
  String get todo_states => 'TODO States';

  @override
  String get todo_state => 'TODO State';

  @override
  String get todo_state_name => 'TODO State Name';

  @override
  String get todo_status_todo => 'todo';

  @override
  String get todo_status_done => 'done';

  @override
  String get todo_status_ignored => 'ignored';

  @override
  String get debug => 'Debug';

  @override
  String get edit_event => 'Edit Event';

  @override
  String get add_event => 'Add Event';

  @override
  String get event_title => 'Event title';

  @override
  String get heading_title => 'Heading title';

  @override
  String get title => 'Title';

  @override
  String get when => 'When';

  @override
  String get choose_date_and_time => 'Choose date and time';

  @override
  String get change_date_and_time => 'Change date and time';

  @override
  String get no_date_selected => 'No date selected';

  @override
  String get need_inbox_file => 'You need to set an inbox file';

  @override
  String get select_date => 'Select Date';

  @override
  String get start_date => 'Start Date';

  @override
  String get start_time => 'Start Time';

  @override
  String get end_date => 'End Date';

  @override
  String get end_time => 'End Time';

  @override
  String get select_end_date => 'select end date';

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
}
