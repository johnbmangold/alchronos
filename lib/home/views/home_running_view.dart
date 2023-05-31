import 'dart:async';

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
  int _timeInSeconds = 3600;
  final oneSecond = const Duration(seconds: 1);
  String _formattedDuration = '';
  late DateTime _endingTime;
  double opacity = 0.0;

  @override
  void initState() {
    super.initState();
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
          Column(
            children: [
              _buildWaveWidget(500, 20),
              Flexible(
                flex: 100,
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.run_circle_rounded,
                size: 60,
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
      oneSecond,
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
    opacity = (3600 - timeDifference.inSeconds) / 3600;
    _formattedDuration = _format(timeDifference);
  }

  String _format(Duration duration) {
    final initialFormat = duration.toString().split('.').first.padLeft(8, '0');
    return initialFormat.substring(initialFormat.indexOf(':') + 1);
  }

  WaveWidget _buildWaveWidget(double width, double height) {
    const backgroundColor = Color(0xFFF15BB5);

    const colors = [
      Color(0xFFFEE440),
      Color(0xFF00BBF9),
    ];

    const durations = [
      5000,
      4000,
    ];

    const heightPercentages = [
      0.65,
      0.66,
    ];

    return WaveWidget(
      config: CustomConfig(
        colors: colors,
        durations: durations,
        heightPercentages: heightPercentages,
      ),
      backgroundColor: backgroundColor,
      size: Size(width, height),
      waveAmplitude: 0,
    );
  }
}
