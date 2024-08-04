import 'package:alchronos/about/views/about_screen.dart';
import 'package:alchronos/home/cubit/home_cubit.dart';
import 'package:alchronos/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
              await cubit.getPreferredDuration().then((duration) async {
                await showModalBottomSheet<Container>(
                  context: context,
                  builder: (localContext) => HomeBottomSheet(
                    l10n: AppLocalizations.of(context)!,
                    cubit: cubit,
                    initialDuration: duration,
                  ),
                );
              });
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
            if (MediaQuery.of(context).platformBrightness == Brightness.light)
              _OverflowLottieAsset(
                assetName: 'assets/lottie/waitDrinkLight.json',
                overflowWidthHeight: lottieOverflowWidthHeight,
                widthHeight: lottieWidthHeight,
                key: const Key('waitDrinkLight'),
              )
            else
              _OverflowLottieAsset(
                assetName: 'assets/lottie/waitDrinkDark.json',
                overflowWidthHeight: lottieOverflowWidthHeight,
                widthHeight: lottieWidthHeight,
                key: const Key('waitDrinkDark'),
              ),
            const SizedBox(
              height: 16,
            ),
            FilledButton(
              key: const Key('drinkButton'),
              onPressed: cubit.start,
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
        child: Lottie.asset(
          assetName,
        ),
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
  longest(minutes: 120);

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

  @override
  void initState() {
    super.initState();
    _currentDuration = widget.initialDuration;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          ListTile(
            title:
                Text(widget.l10n.minutesLabel(TimerDuration.standard.minutes)),
            leading: Radio<TimerDuration>(
              value: TimerDuration.standard,
              groupValue: _currentDuration,
              onChanged: (newDuration) async =>
                  _setCurrentDuration(context, newDuration),
            ),
            onTap: () async {
              await _setCurrentDuration(context, TimerDuration.standard);
            },
          ),
          ListTile(
            title: Text(widget.l10n.minutesLabel(TimerDuration.longer.minutes)),
            leading: Radio<TimerDuration>(
              value: TimerDuration.longer,
              groupValue: _currentDuration,
              onChanged: (newDuration) async =>
                  _setCurrentDuration(context, newDuration),
            ),
            onTap: () async {
              await _setCurrentDuration(context, TimerDuration.longer);
            },
          ),
          ListTile(
            title:
                Text(widget.l10n.minutesLabel(TimerDuration.longest.minutes)),
            leading: Radio<TimerDuration>(
              value: TimerDuration.longest,
              groupValue: _currentDuration,
              onChanged: (newDuration) async =>
                  _setCurrentDuration(context, newDuration),
            ),
            onTap: () async {
              await _setCurrentDuration(context, TimerDuration.longest);
            },
          ),
        ],
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

    await widget.cubit
        .writedPreferredDuration(_currentDuration!)
        .then((_) => Navigator.of(context).pop());
  }
}
