import 'package:alchronos/about/views/about_screen.dart';
import 'package:alchronos/infrastructure/services/performance_service.dart';
import 'package:alchronos/l10n/app_localizations.dart';
import 'package:alchronos/main.dart';
import 'package:alchronos/presentation/home/home_notifier.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lottie/lottie.dart';

/// The default view displayed on the home screen when no timer is active.
class HomeStartView extends ConsumerWidget {
  /// Creates a [HomeStartView].
  const HomeStartView({super.key});

  /// The dimensions of the inner animation asset.
  double get lottieWidthHeight => 100;

  /// The dimension used for containing the overflowing animation box.
  double get lottieOverflowWidthHeight => 200;

  Future<void> _startQuickTimer(
    WidgetRef ref,
    AppLocalizations l10n,
    int minutes,
  ) async {
    final notifier = ref.read(homeNotifierProvider.notifier);

    // Track interaction
    ref.read(performanceServiceProvider).trackUserInteraction(
          'quick_preset_${minutes}min',
          screen: 'home_start',
        );

    // Start timer (haptics and audio are handled in the use case)
    await notifier.writeCustomDuration(minutes);
    await notifier.start(l10n.drinkTimerComplete, l10n.notificationMessage);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final durationAsync = ref.watch(currentTimerDurationProvider);
    final notifier = ref.read(homeNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () async {
              final durationValue = durationAsync.value ?? 60;
              // Determine if it's standard, longer, longest, or custom
              var initialDuration = TimerDuration.custom;
              if (durationValue == 60) {
                initialDuration = TimerDuration.standard;
              } else if (durationValue == 90) {
                initialDuration = TimerDuration.longer;
              } else if (durationValue == 120) {
                initialDuration = TimerDuration.longest;
              }

              if (context.mounted) {
                await showModalBottomSheet<Container>(
                  context: context,
                  builder: (localContext) => HomeBottomSheet(
                    l10n: l10n,
                    initialDuration: initialDuration,
                    currentMinutes: durationValue,
                  ),
                );
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                durationAsync.when(
                  data: (minutes) => Text(l10n.minutesLabel(minutes)),
                  loading: () => const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (_, __) => Text(l10n.minutesLabel(60)),
                ),
                const Icon(Icons.arrow_drop_down, size: 20),
              ],
            ),
          ),
        ],
      ),
      drawer: const HomeDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _OverflowLottieAsset(
              assetName:
                  MediaQuery.of(context).platformBrightness == Brightness.light
                      ? 'assets/lottie/waitDrinkLight.json'
                      : 'assets/lottie/waitDrinkDark.json',
              overflowWidthHeight: lottieOverflowWidthHeight,
              widthHeight: lottieWidthHeight,
              key: const Key('waitDrinkAnimation'),
            ),
            const SizedBox(height: 24),
            // Quick Timer Presets
            Text(
              l10n.quickPresets,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _QuickPresetButton(
                  minutes: 15,
                  onPressed: () => _startQuickTimer(ref, l10n, 15),
                ),
                _QuickPresetButton(
                  minutes: 30,
                  onPressed: () => _startQuickTimer(ref, l10n, 30),
                ),
                _QuickPresetButton(
                  minutes: 45,
                  onPressed: () => _startQuickTimer(ref, l10n, 45),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Main Drink Button
            FilledButton(
              key: const Key('drinkButton'),
              onPressed: () async {
                ref.read(performanceServiceProvider).trackUserInteraction(
                      'start_timer',
                      screen: 'home_start',
                    );

                await notifier.start(
                  l10n.drinkTimerComplete,
                  l10n.notificationMessage,
                );
              },
              style: FilledButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: Text(
                l10n.drinkButtonText,
                style: const TextStyle(fontSize: 36),
                semanticsLabel: l10n.drinkButtonSemanticsLabel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverflowLottieAsset extends StatelessWidget {
  const _OverflowLottieAsset({
    required this.assetName,
    required this.overflowWidthHeight,
    required this.widthHeight,
    super.key,
  });

  final String assetName;
  final double widthHeight;
  final double overflowWidthHeight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widthHeight,
      width: widthHeight,
      child: OverflowBox(
        minHeight: overflowWidthHeight,
        maxHeight: overflowWidthHeight,
        minWidth: overflowWidthHeight,
        maxWidth: overflowWidthHeight,
        child: Lottie.asset(assetName),
      ),
    );
  }
}

/// The primary navigation drawer for the Home screen.
class HomeDrawer extends StatelessWidget {
  /// Creates a [HomeDrawer].
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).extension<CustomColors>()!.brand,
            ),
            child: Text(
              l10n.appName,
              semanticsLabel: l10n.drawerTitleSemanticsLabel,
              style: const TextStyle(color: Colors.black),
            ),
          ),
          ListTile(
            title: Text(
              l10n.drawerAbout,
              semanticsLabel: l10n.drawerAboutSemanticsLabel,
            ),
            onTap: () async {
              Navigator.pop(context);
              await Navigator.of(context).push(AboutScreen.route);
            },
          ),
        ],
      ),
    );
  }
}

/// Represents the available timer durations for the user to select from.
enum TimerDuration implements Comparable<TimerDuration> {
  /// Standard duration of 60 minutes.
  standard(minutes: 60),

  /// Longer duration of 90 minutes.
  longer(minutes: 90),

  /// Longest duration of 120 minutes.
  longest(minutes: 120),

  /// A custom duration specified by the user.
  custom(minutes: 0);

  /// Creates a [TimerDuration] specifying the length in [minutes].
  const TimerDuration({required this.minutes});

  /// The duration length in minutes.
  final int minutes;

  @override
  int compareTo(TimerDuration other) => minutes - other.minutes;

  /// Returns the enum value corresponding to the given string [name].
  static TimerDuration fromString(String name) =>
      TimerDuration.values.firstWhere(
        (element) => element.name == name,
        orElse: () => TimerDuration.standard,
      );

  /// Retrieves the equivalent duration in seconds.
  int get minutesToSeconds => minutes * 60;

  /// Returns true if this is the custom duration variant.
  bool get isCustom => this == TimerDuration.custom;
}

/// A bottom sheet for selecting the preferred timer duration.
class HomeBottomSheet extends ConsumerStatefulWidget {
  /// Creates a [HomeBottomSheet] with the given [initialDuration]
  /// and [currentMinutes].
  const HomeBottomSheet({
    required this.l10n,
    required this.initialDuration,
    required this.currentMinutes,
    super.key,
  });

  /// The app localizations.
  final AppLocalizations l10n;

  /// The initial duration selected in the radio buttons.
  final TimerDuration initialDuration;

  /// The current timer length in minutes if custom was selected.
  final int currentMinutes;

  @override
  ConsumerState<HomeBottomSheet> createState() => _HomeBottomSheetState();
}

class _HomeBottomSheetState extends ConsumerState<HomeBottomSheet> {
  TimerDuration? _currentDuration = TimerDuration.standard;
  final TextEditingController _customMinutesController =
      TextEditingController();
  int _customMinutes = 60;

  @override
  void initState() {
    super.initState();
    _currentDuration = widget.initialDuration;
    if (_currentDuration?.isCustom ?? false) {
      _customMinutes = widget.currentMinutes;
      _customMinutesController.text = _customMinutes.toString();
    }
  }

  @override
  void dispose() {
    _customMinutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: RadioGroup<TimerDuration>(
        groupValue: _currentDuration,
        onChanged: (newDuration) async {
          if (newDuration == TimerDuration.custom) {
            setState(() {
              _currentDuration = newDuration;
            });
          } else {
            await _setCurrentDuration(context, newDuration);
          }
        },
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                  widget.l10n.minutesLabel(TimerDuration.standard.minutes),
                ),
                leading: const Radio<TimerDuration>(
                  value: TimerDuration.standard,
                ),
                onTap: () async {
                  await _setCurrentDuration(context, TimerDuration.standard);
                },
              ),
              ListTile(
                title: Text(
                  widget.l10n.minutesLabel(TimerDuration.longer.minutes),
                ),
                leading: const Radio<TimerDuration>(
                  value: TimerDuration.longer,
                ),
                onTap: () async {
                  await _setCurrentDuration(context, TimerDuration.longer);
                },
              ),
              ListTile(
                title: Text(
                  widget.l10n.minutesLabel(TimerDuration.longest.minutes),
                ),
                leading: const Radio<TimerDuration>(
                  value: TimerDuration.longest,
                ),
                onTap: () async {
                  await _setCurrentDuration(context, TimerDuration.longest);
                },
              ),
              ListTile(
                title: Text(widget.l10n.customDuration),
                leading: const Radio<TimerDuration>(
                  value: TimerDuration.custom,
                ),
              ),
              if (_currentDuration == TimerDuration.custom) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _customMinutesController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: widget.l10n.customMinutesLabel,
                      hintText: '60',
                      suffixText: widget.l10n.minutes,
                    ),
                    onChanged: (value) {
                      final minutes = int.tryParse(value);
                      if (minutes != null && minutes > 0) {
                        setState(() {
                          _customMinutes = minutes;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await _setCurrentDuration(
                          context,
                          TimerDuration.custom,
                        );
                      },
                      child: Text(widget.l10n.done),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _setCurrentDuration(
    BuildContext context,
    TimerDuration? timerDuration,
  ) async {
    setState(() {
      _currentDuration = timerDuration;
    });

    if (_currentDuration == null) {
      Navigator.of(context).pop();
      return;
    }

    final notifier = ref.read(homeNotifierProvider.notifier);

    var durationToSave = _currentDuration!;
    if (_currentDuration == TimerDuration.custom) {
      durationToSave = TimerDuration.custom;
      await notifier.writeCustomDuration(_customMinutes);
    }

    await notifier.writePreferredDuration(durationToSave);

    if (context.mounted) Navigator.of(context).pop();
  }
}

class _QuickPresetButton extends StatelessWidget {
  const _QuickPresetButton({
    required this.minutes,
    required this.onPressed,
  });

  final int minutes;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Start $minutes minute timer',
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$minutes m',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$minutes min',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
