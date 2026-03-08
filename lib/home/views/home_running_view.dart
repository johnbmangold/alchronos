import 'dart:async';

import 'package:alchronos/app_database.dart';
import 'package:alchronos/home/cubit/home_cubit.dart';
import 'package:alchronos/l10n/app_localizations.dart';
import 'package:alchronos/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

class HomeRunningView extends StatefulWidget {
  const HomeRunningView({
    required this.partialRunData,
    required this.totalDurationInSeconds,
    super.key,
  });

  final PartialRunData partialRunData;
  final int totalDurationInSeconds;

  @override
  State<StatefulWidget> createState() => _HomeRunningViewState();
}

class _HomeRunningViewState extends State<HomeRunningView>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late Timer _timer;
  final _oneSecond = const Duration(seconds: 1);
  String _formattedDuration = '';
  double _opacity = 0;
  late int _timeInSeconds;
  late final HomeCubit cubit;
  final double lottieWidthHeight = 100;
  late final AnimationController _controller;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this);
    WidgetsBinding.instance.addObserver(this);
    cubit = BlocProvider.of<HomeCubit>(context);
    _getDurationSeconds();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer.cancel();
    _controller.dispose();
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
              Lottie.asset(
                MediaQuery.of(context).platformBrightness == Brightness.light
                    ? 'assets/lottie/activeDrinkLight.json'
                    : 'assets/lottie/activeDrinkDark.json',
                key: const Key('activeDrinkAnimation'),
                width: lottieWidthHeight,
                height: lottieWidthHeight,
                controller: _controller,
                onLoaded: (composition) async {
                  _controller.duration = composition.duration;
                  await _startAnimationController();
                },
              ),
              const SizedBox(height: 16),
              // Circular Progress Indicator
              Semantics(
                label: 'Timer progress: ${(_opacity * 100).round()}% complete',
                value: _formattedDuration,
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background circle
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(
                                alpha: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? 0.5
                                    : 0.3,
                              ),
                        ),
                      ),
                      // Progress circle
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: CircularProgressIndicator(
                          value: _opacity,
                          strokeWidth: 8,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      // Timer text in center
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _formattedDuration,
                            key: const Key('runningTimer'),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                            semanticsLabel: l10n.runningTimerSemanticsLabel,
                          ),
                          if (_isPaused)
                            Text(
                              l10n.paused,
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isPaused)
                    Semantics(
                      button: true,
                      label: 'Resume timer',
                      child: ElevatedButton.icon(
                        onPressed: _resumeTimer,
                        icon: const Icon(Icons.play_arrow),
                        label: Text(l10n.resumeTimer),
                        key: const Key('resumeButton'),
                      ),
                    )
                  else
                    Semantics(
                      button: true,
                      label: 'Pause timer',
                      child: ElevatedButton.icon(
                        onPressed: _pauseTimer,
                        icon: const Icon(Icons.pause),
                        label: Text(l10n.pauseTimer),
                        key: const Key('pauseButton'),
                      ),
                    ),
                  const SizedBox(width: 16),
                  Semantics(
                    button: true,
                    label: 'Stop timer',
                    child: ElevatedButton.icon(
                      onPressed: () => cubit.reset(),
                      icon: const Icon(Icons.stop),
                      label: Text(l10n.stopTimer),
                      key: const Key('stopButton'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        foregroundColor: Theme.of(context).colorScheme.onError,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _startAnimationController() async {
    const start = 0.0;
    const stop = .78;
    await _controller.repeat(
      reverse: true,
      min: start,
      max: stop,
      period: _controller.duration! * (stop - start),
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(_oneSecond, (timer) {
      if (_timeInSeconds <= 0) {
        _timer.cancel();
        // This is intentionally not awaited as we don't need
        // to wait for the reset to complete
        unawaited(cubit.reset());
      } else if (!_isPaused) {
        _timeInSeconds--;
        _calculateTimeDisplay();
        // Only call setState if the display actually changed
        if (mounted) {
          setState(() {});
        }
      }
    });
  }

  Future<void> _pauseTimer() async {
    setState(() {
      _isPaused = true;
    });
    await cubit.pauseTimer();
  }

  Future<void> _resumeTimer() async {
    setState(() {
      _isPaused = false;
    });
    await cubit.resumeTimer();
  }

  void _calculateTimeDisplay() {
    final timeDifference = Duration(seconds: _timeInSeconds);
    final calculatedOpacity =
        (widget.totalDurationInSeconds - timeDifference.inSeconds) /
            widget.totalDurationInSeconds;
    _opacity = switch (calculatedOpacity) {
      < 0.0 => 0.0,
      > 1.0 => 1.0,
      _ => calculatedOpacity,
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
    final colors = [drinkColorStart];

    const durations = [5000];

    const heightPercentages = [0.75];

    return WaveWidget(
      config: CustomConfig(
        colors: colors,
        durations: durations,
        heightPercentages: heightPercentages,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      size: Size(width, height),
      waveAmplitude: 0,
    );
  }

  void _getDurationSeconds() {
    if (widget.partialRunData.endTime.isBefore(DateTime.now())) {
      // This is intentionally not awaited
      // as we don't need to wait for the reset to complete
      unawaited(cubit.reset());
    }
    // get remaining seconds
    final seconds =
        widget.partialRunData.endTime.difference(DateTime.now()).inSeconds;

    // use partial run to calculate _timeInSeconds
    _timeInSeconds = seconds;
    _calculateTimeDisplay();
    _startTimer();
  }
}
