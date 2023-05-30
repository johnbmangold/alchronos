import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_app/home/cubit/home_cubit.dart';

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
      child: Column(
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
    _formattedDuration = _format(timeDifference);
  }

  String _format(Duration duration) {
    final initialFormat = duration.toString().split('.').first.padLeft(8, '0');
    return initialFormat.substring(initialFormat.indexOf(':') + 1);
  }
}
