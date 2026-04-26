import 'dart:async';

import 'package:alchronos/home/views/home_running_view.dart';
import 'package:alchronos/home/views/home_start_view.dart';
import 'package:alchronos/home/views/loading_view.dart';
import 'package:alchronos/presentation/home/home_notifier.dart';
import 'package:alchronos/presentation/home/home_state.dart';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  static MaterialPageRoute<HomeScreen> get route =>
      MaterialPageRoute(builder: (context) => const HomeScreen());

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize the home notifier
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(ref.read(homeNotifierProvider.notifier).init());
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: HomeBody(),
    );
  }
}

class HomeBody extends ConsumerWidget {
  const HomeBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeNotifierProvider);

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
        (final HomeError errorState) => _ErrorView(
            message: errorState.message,
            onRetry: () => ref.read(homeNotifierProvider.notifier).init(),
          ),
        (_) => const LoadingView(),
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
