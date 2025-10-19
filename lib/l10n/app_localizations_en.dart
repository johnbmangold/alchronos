// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Alchronos';

  @override
  String get drinkTimerComplete => 'Drink Timer Complete';

  @override
  String get notificationMessage =>
      'You can order another drink when you\'re feeling up to it.';

  @override
  String get drinkIconSemanticsLabel => 'A drink icon';

  @override
  String get drinkButtonSemanticsLabel => 'Drink';

  @override
  String get drinkButtonText => 'Drink!';

  @override
  String get runningIconSemanticsLabel => 'Icon of a running person';

  @override
  String get runningTimerSemanticsLabel =>
      'A timer that counts from 59:59 to zero';

  @override
  String get drawerTitleSemanticsLabel => 'Alchronos';

  @override
  String get drawerAboutSemanticsLabel => 'Text that reads About';

  @override
  String get drawerAbout => 'About';

  @override
  String get aboutAlchronosPart1 =>
      'The consumption of alcohol is never entirely safe and is never healthy.';

  @override
  String get aboutAlchronosPart2 =>
      'As with most things in life moderation is the best practice when consuming alcohol. Alchronos is aimed at making the consumption of alcohol safer and helping to mitigate the dangers.';

  @override
  String get aboutAlchronosPart3 =>
      'With that goal in mind, Alchronos helps to pace drinking to a maximum of one alcoholic beverage per hour so your body can process the alcohol without getting overwhelmed. Please, always drink responsbily and never in excess.';

  @override
  String get aboutAlchronosPart4 =>
      'If you feel you have a drinking problem, please seek treatment.';

  @override
  String get aboutAlchronosTitle => 'About Alchronos';

  @override
  String get backIconSemanticsLabel => 'Back';

  @override
  String minutesLabel(int minutes) {
    return '$minutes minutes';
  }

  @override
  String get pauseTimer => 'Pause';

  @override
  String get resumeTimer => 'Resume';

  @override
  String get stopTimer => 'Stop';

  @override
  String get customDuration => 'Custom';

  @override
  String get customMinutesLabel => 'Minutes';

  @override
  String get minutes => 'min';
}
