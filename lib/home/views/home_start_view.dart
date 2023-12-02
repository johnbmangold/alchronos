import 'package:alchronos/about/views/about_screen.dart';
import 'package:alchronos/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alchronos/home/cubit/home_cubit.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeStartView extends StatelessWidget {
  const HomeStartView({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<HomeCubit>(context);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () async {
              await showModalBottomSheet<Container>(
                context: context,
                builder: (localContext) => HomeBottomSheet(
                  l10n: AppLocalizations.of(context)!,
                  cubit: cubit,
                ),
              );
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
            Icon(
              key: const Key('drinkIcon'),
              Icons.emoji_food_beverage,
              size: 60,
              semanticLabel: l10n.drinkIconSemanticsLabel,
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
  const HomeBottomSheet({super.key, required this.l10n, required this.cubit});

  final AppLocalizations l10n;
  final HomeCubit cubit;

  @override
  State<StatefulWidget> createState() => _HomeBottomSheetState();
}

class _HomeBottomSheetState extends State<HomeBottomSheet> {
  TimerDuration? _currentDuration = TimerDuration.standard;

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
              onChanged: _setCurrentDuration,
            ),
            onTap: () async {
              await _setCurrentDuration(TimerDuration.standard);
            },
          ),
          ListTile(
            title: Text(widget.l10n.minutesLabel(TimerDuration.longer.minutes)),
            leading: Radio<TimerDuration>(
              value: TimerDuration.longer,
              groupValue: _currentDuration,
              onChanged: _setCurrentDuration,
            ),
            onTap: () async {
              await _setCurrentDuration(TimerDuration.longer);
            },
          ),
          ListTile(
            title:
                Text(widget.l10n.minutesLabel(TimerDuration.longest.minutes)),
            leading: Radio<TimerDuration>(
              value: TimerDuration.longest,
              groupValue: _currentDuration,
              onChanged: _setCurrentDuration,
            ),
            onTap: () async {
              await _setCurrentDuration(TimerDuration.longest);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _setCurrentDuration(TimerDuration? timerDuration) async {
    setState(() {
      _currentDuration = timerDuration;
    });

    if (_currentDuration != null) {
      await widget.cubit.writedPreferredDuration(_currentDuration!);
    }
  }
}
