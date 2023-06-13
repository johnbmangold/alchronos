import 'package:alchronos/main.dart';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alchronos/home/cubit/home_cubit.dart';
import 'package:alchronos/home/views/home_running_view.dart';
import 'package:alchronos/home/views/home_start_view.dart';
import 'package:logger/logger.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          child: const Icon(Icons.menu_rounded),
          onTap: () {},
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: BlocProvider(
          create: (context) => HomeCubit(
            logger: getIt.get<Logger>(),
          ),
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              return PageTransitionSwitcher(
                duration: const Duration(milliseconds: 1000),
                transitionBuilder:
                    (child, primaryAnimation, secondaryAnimation) {
                  return FadeThroughTransition(
                    animation: primaryAnimation,
                    secondaryAnimation: secondaryAnimation,
                    child: child,
                  );
                },
                child: switch (state) {
                  (HomeInitial _) => const HomeStartView(),
                  (HomeRunning _) => const HomeRunningView(),
                  (_) => const Center(child: CircularProgressIndicator()),
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
