import 'package:alchronos/about/about.dart';
import 'package:alchronos/home/views/loading_view.dart';
import 'package:alchronos/main.dart';
import 'package:alchronos/repositories/repositories.dart';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alchronos/home/cubit/home_cubit.dart';
import 'package:alchronos/home/views/home_running_view.dart';
import 'package:alchronos/home/views/home_start_view.dart';
import 'package:logger/logger.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static MaterialPageRoute<HomeScreen> get route =>
      MaterialPageRoute(builder: (context) => const HomeScreen());

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).extension<CustomColors>()!.brand,
              ),
              child: Text(
                l10n.appName,
                semanticsLabel: l10n.drawerTitleSemanticsLabel,
                style: const TextStyle(color: Colors.black),
              ),
            ),
            ListTile(
              title: Text(
                l10n.drawerAbout,
                semanticsLabel: l10n.drawerAboutSemanticsLabel,
              ),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.of(context).push(AboutScreen.route);
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: BlocProvider(
          create: (context) => HomeCubit(
            logger: getIt.get<Logger>(),
            partialRunRepository: getIt.get<PartialRunRepository>(),
            // ignore: discarded_futures
          )..init(),
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
                  (HomeStart _) => const HomeStartView(),
                  (HomeRunning runningState) => HomeRunningView(
                      partialRun: runningState.partialRun,
                    ),
                  (_) => const LoadingView(),
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
