import 'dart:async';

import 'package:alchronos/home/home.dart';
import 'package:alchronos/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alchronos/home/cubit/home_cubit.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeRunningView extends StatefulWidget {
  const HomeRunningView({super.key, required this.partialRun});

  final PartialRun? partialRun;

  @override
  State<StatefulWidget> createState() => _HomeRunningViewState();
}

class _HomeRunningViewState extends State<HomeRunningView> {
  late Timer _timer;
  final _oneSecond = const Duration(seconds: 1);
  String _formattedDuration = '';
  double _opacity = 0.0;
  late int _timeInSeconds;

  @override
  void initState() {
    super.initState();

    _getDurationSeconds();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: _opacity,
            child: Column(
              children: [
                _buildWaveWidget(
                  double.infinity,
                  50,
                  customColors.drinkStartColor!,
                ),
                Flexible(
                  flex: 100,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          customColors.drinkStartColor!,
                          customColors.drinkEndColor!,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                key: const Key('runningIcon'),
                Icons.run_circle_rounded,
                size: 60,
                semanticLabel: l10n.runningIconSemanticsLabel,
              ),
              const SizedBox(
                height: 16,
              ),
              Text(
                _formattedDuration,
                key: const Key('runningTimer'),
                style: const TextStyle(fontSize: 36),
                semanticsLabel: l10n.runningTimerSemanticsLabel,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(
      _oneSecond,
      (timer) async {
        if (_timeInSeconds == 0) {
          _timer.cancel();
          await BlocProvider.of<HomeCubit>(context).showNotificationAndStop();
        } else {
          setState(() {
            _timeInSeconds--;
            _calculateTimeDisplay();
          });
        }
      },
    );
  }

  void _calculateTimeDisplay() {
    final timeDifference = Duration(seconds: _timeInSeconds);
    final calculatedOpacity =
        (oneHourInSeconds - timeDifference.inSeconds) / oneHourInSeconds;
    _opacity = switch (calculatedOpacity) {
      < 0.0 => 0.0,
      > 1.0 => 1.0,
      _ => calculatedOpacity
    };
    _formattedDuration = _format(timeDifference);
  }

  String _format(Duration duration) {
    final initialFormat = duration.toString().split('.').first.padLeft(8, '0');
    return initialFormat.substring(initialFormat.indexOf(':') + 1);
  }

  WaveWidget _buildWaveWidget(
    double width,
    double height,
    Color drinkColorStart,
  ) {
    final colors = [
      drinkColorStart,
    ];

    const durations = [
      5000,
    ];

    const heightPercentages = [
      0.75,
    ];

    return WaveWidget(
      config: CustomConfig(
        colors: colors,
        durations: durations,
        heightPercentages: heightPercentages,
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      size: Size(width, height),
      waveAmplitude: 0.0,
    );
  }

  // ignore: avoid_void_async
  void _getDurationSeconds() async {
    // get partial run
    final now = DateTime.now();

    // calculate time
    int seconds = oneHourInSeconds;
    if (widget.partialRun?.endTime == null) {
      // create partialRun and store
      final newPartialRun = PartialRun();
      newPartialRun.secondsRemaining = seconds;
      newPartialRun.endTime = now.add(Duration(seconds: seconds));
      await BlocProvider.of<HomeCubit>(context).setPartialRun(newPartialRun);
    } else {
      // get remaining seconds
      seconds = widget.partialRun!.endTime!.difference(now).inSeconds;
    }

    // use partial run to calculate _timeInSeconds
    _timeInSeconds = seconds;
    _calculateTimeDisplay();
    _startTimer();
  }
}
