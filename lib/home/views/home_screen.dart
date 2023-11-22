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
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static MaterialPageRoute<HomeScreen> get route =>
      MaterialPageRoute(builder: (context) => const HomeScreen());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: const HomeDrawer(),
      body: SafeArea(
        bottom: false,
        child: BlocProvider(
          create: (_) => HomeCubit(
            logger: getIt.get<Logger>(),
            partialRunRepository: getIt.get<PartialRunRepository>(),
            flutterLocalNotificationsPlugin:
                getIt.get<FlutterLocalNotificationsPlugin>(),
            l10n: AppLocalizations.of(context)!,
            // ignore: discarded_futures
          )..init(),
          child: const HomeBody(),
        ),
      ),
    );
  }
}

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Drawer(
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
            (HomeRunning runningState) => HomeRunningView(
                partialRun: runningState.partialRun,
              ),
            (_) => const LoadingView(),
          },
        );
      },
    );
  }
}
