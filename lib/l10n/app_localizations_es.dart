// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Alcronos';

  @override
  String get drinkTimerComplete => 'Temporizador de bebidas completado';

  @override
  String get notificationMessage =>
      'Puedes pedir otra bebida cuando te apetezca.';

  @override
  String get drinkIconSemanticsLabel => 'Un icono de bebida';

  @override
  String get drinkButtonSemanticsLabel => 'Texto en un botón que dice Beber';

  @override
  String get drinkButtonText => '¡Bebe!';

  @override
  String get runningIconSemanticsLabel => 'Icono de una persona corriendo';

  @override
  String get runningTimerSemanticsLabel =>
      'Un temporizador que cuenta desde 59:59 hasta cero';

  @override
  String get drawerTitleSemanticsLabel => 'Alcronos';

  @override
  String get drawerAboutSemanticsLabel => 'Texto que dice Acerca de';

  @override
  String get drawerAbout => 'Acerca de';

  @override
  String get aboutAlchronosPart1 =>
      'El consumo de alcohol nunca es totalmente seguro y nunca es saludable.';

  @override
  String get aboutAlchronosPart2 =>
      'Como ocurre con la mayoría de las cosas de la vida, la moderación es la mejor práctica a la hora de consumir alcohol. Alchronos tiene como objetivo hacer que el consumo de alcohol sea más seguro y ayudar a mitigar los peligros.';

  @override
  String get aboutAlchronosPart3 =>
      'Con ese objetivo en mente, Alchronos ayuda a controlar el consumo de alcohol a un máximo de una bebida alcohólica por hora para que el cuerpo pueda procesar el alcohol sin agobiarse. Por favor, siempre beba de manera responsable y nunca en exceso.';

  @override
  String get aboutAlchronosPart4 =>
      'Si cree que tiene un problema con la bebida, busque tratamiento.';

  @override
  String get aboutAlchronosTitle => 'Acerca de Alchronos';

  @override
  String get backIconSemanticsLabel => 'Volver';

  @override
  String minutesLabel(int minutes) {
    return '$minutes minutos';
  }

  @override
  String get pauseTimer => 'Pausar';

  @override
  String get resumeTimer => 'Reanudar';

  @override
  String get stopTimer => 'Detener';

  @override
  String get customDuration => 'Personalizado';

  @override
  String get customMinutesLabel => 'Minutos';

  @override
  String get minutes => 'min';

  @override
  String get done => 'Hecho';
}
