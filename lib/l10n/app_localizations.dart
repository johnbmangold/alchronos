import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// The name of the application: Alchronos
  ///
  /// In en, this message translates to:
  /// **'Alchronos'**
  String get appName;

  /// Title of the timer complete notification
  ///
  /// In en, this message translates to:
  /// **'Drink Timer Complete'**
  String get drinkTimerComplete;

  /// Message of the timer complete notification
  ///
  /// In en, this message translates to:
  /// **'You can order another drink when you\'re feeling up to it.'**
  String get notificationMessage;

  /// A description of the drink icon for screen readers
  ///
  /// In en, this message translates to:
  /// **'A drink icon'**
  String get drinkIconSemanticsLabel;

  /// A description of the drink button for screen readers
  ///
  /// In en, this message translates to:
  /// **'Drink'**
  String get drinkButtonSemanticsLabel;

  /// Text on the button to start timer: Drink!
  ///
  /// In en, this message translates to:
  /// **'Drink!'**
  String get drinkButtonText;

  /// A description of the running icon for screen readers
  ///
  /// In en, this message translates to:
  /// **'Icon of a running person'**
  String get runningIconSemanticsLabel;

  /// A description of the running timer for screen readers
  ///
  /// In en, this message translates to:
  /// **'A timer that counts from 59:59 to zero'**
  String get runningTimerSemanticsLabel;

  /// A description of the drawer title for screen readers
  ///
  /// In en, this message translates to:
  /// **'Alchronos'**
  String get drawerTitleSemanticsLabel;

  /// A description of the drawer item about for screen readers
  ///
  /// In en, this message translates to:
  /// **'Text that reads About'**
  String get drawerAboutSemanticsLabel;

  /// Drawer option that reads About
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get drawerAbout;

  /// The long about of Alchronos and it's overall goals part 1
  ///
  /// In en, this message translates to:
  /// **'The consumption of alcohol is never entirely safe and is never healthy.'**
  String get aboutAlchronosPart1;

  /// The long about of Alchronos and it's overall goals part 2
  ///
  /// In en, this message translates to:
  /// **'As with most things in life moderation is the best practice when consuming alcohol. Alchronos is aimed at making the consumption of alcohol safer and helping to mitigate the dangers.'**
  String get aboutAlchronosPart2;

  /// The long about of Alchronos and it's overall goals part 3
  ///
  /// In en, this message translates to:
  /// **'With that goal in mind, Alchronos helps to pace drinking to a maximum of one alcoholic beverage per hour so your body can process the alcohol without getting overwhelmed. Please, always drink responsbily and never in excess.'**
  String get aboutAlchronosPart3;

  /// The long about of Alchronos and it's overall goals part 4
  ///
  /// In en, this message translates to:
  /// **'If you feel you have a drinking problem, please seek treatment.'**
  String get aboutAlchronosPart4;

  /// Title of the About page
  ///
  /// In en, this message translates to:
  /// **'About Alchronos'**
  String get aboutAlchronosTitle;

  /// TalkBack label for back arrow
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backIconSemanticsLabel;

  /// Label for duration length in minutes
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes'**
  String minutesLabel(int minutes);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
