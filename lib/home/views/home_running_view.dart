import 'dart:async';

import 'package:alchronos/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alchronos/home/cubit/home_cubit.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

class HomeRunningView extends StatefulWidget {
  const HomeRunningView({super.key});

  @override
  State<StatefulWidget> createState() => _HomeRunningViewState();
}

class _HomeRunningViewState extends State<HomeRunningView> {
  late Timer _timer;
  final _oneSecond = const Duration(seconds: 1);
  String _formattedDuration = '';
  late DateTime _endingTime;
  double _opacity = 0.0;
  final _drinkColorStart = Colors.amber.shade300;
  final _drinkColorEnd = Colors.amberAccent.shade700;
  late int _timeInSeconds;

  @override
  void initState() {
    super.initState();
    _timeInSeconds = oneHourInSeconds;
    _endingTime = DateTime.now().add(const Duration(hours: 1));
    _calculateTimeDisplay();
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: _opacity,
            child: Column(
              children: [
                _buildWaveWidget(double.infinity, 50),
                Flexible(
                  flex: 100,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _drinkColorStart,
                          _drinkColorEnd,
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
              const Icon(
                Icons.run_circle_rounded,
                size: 60,
              ),
              const SizedBox(
                height: 16,
              ),
              Text(
                _formattedDuration,
                style: const TextStyle(fontSize: 36),
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
      (timer) {
        if (_timeInSeconds == 0) {
          setState(() {
            _timer.cancel();
            BlocProvider.of<HomeCubit>(context).stop();
          });
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
    final timeDifference = _endingTime.difference(DateTime.now());
    _opacity = (oneHourInSeconds - timeDifference.inSeconds) / oneHourInSeconds;
    _formattedDuration = _format(timeDifference);
  }

  String _format(Duration duration) {
    final initialFormat = duration.toString().split('.').first.padLeft(8, '0');
    return initialFormat.substring(initialFormat.indexOf(':') + 1);
  }

  WaveWidget _buildWaveWidget(double width, double height) {
    final colors = [
      _drinkColorStart,
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
}
