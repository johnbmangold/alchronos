import 'package:alchronos/about/views/about_screen.dart';
import 'package:alchronos/configurator.dart';
import 'package:alchronos/home/cubit/home_cubit.dart';
import 'package:alchronos/l10n/app_localizations.dart';
import 'package:alchronos/main.dart';
import 'package:alchronos/services/audio_service.dart';
import 'package:alchronos/services/haptic_service.dart';
import 'package:alchronos/services/performance_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

class HomeStartView extends StatelessWidget {
  const HomeStartView({super.key});

  double get lottieWidthHeight => 100;

  Future<void> _startQuickTimer(
    BuildContext context,
    HomeCubit cubit,
    AppLocalizations l10n,
    int minutes,
  ) async {
    // Add haptic and audio feedback
    final hapticService = getIt.get<HapticService>();
    final audioService = getIt.get<AudioService>();
    getIt.get<PerformanceService>().trackUserInteraction(
          'quick_preset_${minutes}min',
          screen: 'home_start',
        );
    await hapticService.lightImpact();
    await audioService.playButtonClickSound();

    // Set custom duration and start timer
    await cubit.writeCustomDuration(minutes);
    await cubit.start(l10n.drinkTimerComplete, l10n.notificationMessage);
  }

  double get lottieOverflowWidthHeight => 200;

  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<HomeCubit>(context);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () async {
              final duration = await cubit.getPreferredDuration();
              if (context.mounted) {
                await showModalBottomSheet<Container>(
                  context: context,
                  builder: (localContext) => HomeBottomSheet(
                    l10n: AppLocalizations.of(context)!,
                    cubit: cubit,
                    initialDuration: duration,
                  ),
                );
              }
            },
            child: StreamBuilder(
              stream: cubit.durationStream,
              builder: (buildContext, snapshot) {
                String minutesText;
                if (snapshot.hasData && snapshot.data != null) {
                  minutesText = l10n.minutesLabel(snapshot.data!);
                } else {
                  minutesText =
                      l10n.minutesLabel(TimerDuration.standard.minutes);
                }

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(minutesText),
                    const Icon(Icons.arrow_drop_down, size: 20),
                  ],
                );
              },
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
                  onPressed: () => _startQuickTimer(context, cubit, l10n, 15),
                ),
                _QuickPresetButton(
                  minutes: 30,
                  onPressed: () => _startQuickTimer(context, cubit, l10n, 30),
                ),
                _QuickPresetButton(
                  minutes: 45,
                  onPressed: () => _startQuickTimer(context, cubit, l10n, 45),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Main Drink Button
            FilledButton(
              key: const Key('drinkButton'),
              onPressed: () async {
                // Add haptic and audio feedback
                final hapticService = getIt.get<HapticService>();
                final audioService = getIt.get<AudioService>();
                getIt.get<PerformanceService>().trackUserInteraction(
                      'start_timer',
                      screen: 'home_start',
                    );
                await hapticService.mediumImpact();
                await audioService.playButtonClickSound();

                await cubit.start(
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

class HomeDrawer extends StatelessWidget {
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

enum TimerDuration implements Comparable<TimerDuration> {
  standard(minutes: 60),
  longer(minutes: 90),
  longest(minutes: 120),
  custom(minutes: 0);

  const TimerDuration({required this.minutes});

  final int minutes;

  @override
  int compareTo(TimerDuration other) => minutes - other.minutes;

  static TimerDuration fromString(String name) =>
      TimerDuration.values.firstWhere(
        (element) => element.name == name,
        orElse: () => TimerDuration.standard,
      );

  int get minutesToSeconds => minutes * 60;

  bool get isCustom => this == TimerDuration.custom;
}

class HomeBottomSheet extends StatefulWidget {
  const HomeBottomSheet({
    required this.l10n,
    required this.cubit,
    required this.initialDuration,
    super.key,
  });

  final AppLocalizations l10n;
  final HomeCubit cubit;
  final TimerDuration initialDuration;

  @override
  State<StatefulWidget> createState() => _HomeBottomSheetState();
}

class _HomeBottomSheetState extends State<HomeBottomSheet> {
  TimerDuration? _currentDuration = TimerDuration.standard;
  final TextEditingController _customMinutesController =
      TextEditingController();
  int _customMinutes = 60;

  @override
  void initState() {
    super.initState();
    _currentDuration = widget.initialDuration;
    if (_currentDuration?.isCustom ?? false) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _loadCustomDuration();
      });
    }
  }

  Future<void> _loadCustomDuration() async {
    try {
      // Access storage repository through the cubit
      final storageRepo = widget.cubit.storageRepository;
      final customMinutes = await storageRepo.readCustomDuration();
      setState(() {
        _customMinutes = customMinutes;
        _customMinutesController.text = customMinutes.toString();
      });
    } on Exception {
      // Fallback to default value if loading fails
      setState(() {
        _customMinutes = 60;
        _customMinutesController.text = '60';
      });
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
            // Don't close the bottom sheet for custom duration
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

    // For custom duration, we need to create a custom
    // TimerDuration with the specified minutes
    var durationToSave = _currentDuration!;
    if (_currentDuration == TimerDuration.custom) {
      durationToSave = TimerDuration.custom;
      // We'll store the custom minutes separately
      await widget.cubit.writeCustomDuration(_customMinutes);
    }

    await widget.cubit.writedPreferredDuration(durationToSave);

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
