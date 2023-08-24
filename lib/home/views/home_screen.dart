import 'package:alchronos/main.dart';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alchronos/home/cubit/home_cubit.dart';
import 'package:alchronos/home/views/home_running_view.dart';
import 'package:alchronos/home/views/home_start_view.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
              onTap: () {
                Navigator.pop(context);
                context.goNamed('about');
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
