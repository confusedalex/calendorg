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

  static CalendorgLocalizations? of(BuildContext context) {
    return Localizations.of<CalendorgLocalizations>(
      context,
      CalendorgLocalizations,
    );
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

  /// No description provided for @file_could_not_open.
  ///
  /// In en, this message translates to:
  /// **'File could not be opened!'**
  String get file_could_not_open;

  /// No description provided for @file_already_exists.
  ///
  /// In en, this message translates to:
  /// **'File does already exist!'**
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
  /// **'File name could\'t not be loaded'**
  String get file_name_couldnt_load;
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
