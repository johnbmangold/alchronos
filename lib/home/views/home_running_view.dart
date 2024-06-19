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
  const HomeRunningView({
    super.key,
    required this.partialRun,
    required this.totalDurationInSeconds,
  });

  final PartialRun partialRun;
  final int totalDurationInSeconds;

  @override
  State<StatefulWidget> createState() => _HomeRunningViewState();
}

class _HomeRunningViewState extends State<HomeRunningView>
    with WidgetsBindingObserver {
  late Timer _timer;
  final _oneSecond = const Duration(seconds: 1);
  String _formattedDuration = '';
  double _opacity = 0.0;
  late int _timeInSeconds;
  late final HomeCubit cubit;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    cubit = BlocProvider.of<HomeCubit>(context);
    _getDurationSeconds();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      _getDurationSeconds();
    }
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

  void _startTimer() {
    _timer = Timer.periodic(
      _oneSecond,
      (timer) {
        if (_timeInSeconds <= 0) {
          _timer.cancel();
          cubit.reset();
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
        (widget.totalDurationInSeconds - timeDifference.inSeconds) /
            widget.totalDurationInSeconds;
    _opacity = switch (calculatedOpacity) {
      < 0.0 => 0.0,
      > 1.0 => 1.0,
      _ => calculatedOpacity
    };
    _formattedDuration = _format(timeDifference);
  }

  String _format(Duration duration) {
    final initialFormat = duration.toString().split('.').first.padLeft(8, '0');
    if (duration.inMinutes > 59) {
      return initialFormat;
    }

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
      backgroundColor: Theme.of(context).colorScheme.surface,
      size: Size(width, height),
      waveAmplitude: 0.0,
    );
  }

  void _getDurationSeconds() {
    if (widget.partialRun.endTime == null ||
        widget.partialRun.endTime!.isBefore(DateTime.now())) {
      cubit.reset();
    }
    // get remaining seconds
    final seconds =
        widget.partialRun.endTime!.difference(DateTime.now()).inSeconds;

    // use partial run to calculate _timeInSeconds
    _timeInSeconds = seconds;
    _calculateTimeDisplay();
    _startTimer();
  }
}
