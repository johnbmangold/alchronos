import 'package:alchronos/about/views/about_screen.dart';
import 'package:alchronos/home/cubit/home_cubit.dart';
import 'package:alchronos/l10n/app_localizations.dart';
import 'package:alchronos/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

class HomeStartView extends StatelessWidget {
  const HomeStartView({super.key});

  double get lottieWidthHeight => 100;
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
                if (snapshot.hasData && snapshot.data != null) {
                  return Text(l10n.minutesLabel(snapshot.data!));
                }

                return Text(l10n.minutesLabel(TimerDuration.standard.minutes));
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
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('drinkButton'),
              onPressed: () => cubit.start(
                l10n.drinkTimerComplete,
                l10n.notificationMessage,
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
      _customMinutes = _currentDuration!.minutes;
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
      height: _currentDuration == TimerDuration.custom ? 400 : 300,
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
        child: Column(
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
                      await _setCurrentDuration(context, TimerDuration.custom);
                    },
                    child: Text(widget.l10n.done),
                  ),
                ),
              ),
            ],
          ],
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
