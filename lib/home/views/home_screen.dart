import 'package:alchronos/configurator.dart';
import 'package:alchronos/home/cubit/home_cubit.dart';
import 'package:alchronos/home/views/home_running_view.dart';
import 'package:alchronos/home/views/home_start_view.dart';
import 'package:alchronos/home/views/loading_view.dart';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static MaterialPageRoute<HomeScreen> get route =>
      MaterialPageRoute(builder: (context) => const HomeScreen());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Scaffold(
        body: BlocProvider(
          create: (_) => getIt.get<HomeCubit>()..init(),
          child: const HomeBody(),
        ),
      ),
    );
  }
}

class HomeBody extends StatelessWidget {
  const HomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return PageTransitionSwitcher(
          duration: const Duration(milliseconds: 1000),
          transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
            return FadeThroughTransition(
              animation: primaryAnimation,
              secondaryAnimation: secondaryAnimation,
              child: child,
            );
          },
          child: switch (state) {
            (HomeStart _) => const HomeStartView(),
            (final HomeRunning runningState) => HomeRunningView(
                partialRunData: runningState.partialRunData,
                totalDurationInSeconds: runningState.totalDurationInSeconds,
              ),
            (_) => const LoadingView(),
          },
        );
      },
    );
  }
}
