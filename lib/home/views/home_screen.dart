import 'package:alchronos/configurator.dart';
import 'package:alchronos/home/cubit/home_cubit.dart';
import 'package:alchronos/home/views/home_running_view.dart';
import 'package:alchronos/home/views/home_start_view.dart';
import 'package:alchronos/home/views/loading_view.dart';
import 'package:alchronos/repositories/repositories.dart';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';

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
          create: (_) => HomeCubit(
            logger: getIt.get<Logger>(),
            partialRunRepository: getIt.get<PartialRunRepository>(),
            flutterLocalNotificationsPlugin:
                getIt.get<FlutterLocalNotificationsPlugin>(),
            l10n: AppLocalizations.of(context)!,
            storageRepository: getIt.get<StorageRepository>(),
            // ignore: discarded_futures
          )..init(),
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
                partialRun: runningState.partialRun,
                totalDurationInSeconds: runningState.totalDurationInSeconds,
              ),
            (_) => const LoadingView(),
          },
        );
      },
    );
  }
}
