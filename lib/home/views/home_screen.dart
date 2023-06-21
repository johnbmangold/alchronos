import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alchronos/home/cubit/home_cubit.dart';
import 'package:alchronos/home/views/home_running_view.dart';
import 'package:alchronos/home/views/home_start_view.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.logger});

  final Logger logger;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xfff8bbd0)),
              child: Text(
                'Alchronos',
                semanticsLabel: 'The app name Alchronos',
              ),
            ),
            ListTile(
              title: const Text(
                'About',
                semanticsLabel: 'Text that reads About',
              ),
              onTap: () {
                Navigator.pop(context);
                context.goNamed('about');
              },
            )
          ],
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: BlocProvider(
          create: (context) => HomeCubit(
            logger: logger,
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
