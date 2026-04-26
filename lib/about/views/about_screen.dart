import 'package:alchronos/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// The screen displaying information about the Alchronos application.
class AboutScreen extends StatelessWidget {
  /// Creates an [AboutScreen].
  const AboutScreen({super.key});

  /// The default [MaterialPageRoute] for navigating to this screen.
  static MaterialPageRoute<AboutScreen> get route =>
      MaterialPageRoute(builder: (context) => const AboutScreen());

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutAlchronosTitle), centerTitle: true),
      body: Column(
        children: [
          Card.outlined(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                spacing: 16,
                children: [
                  Text(l10n.aboutAlchronosPart1),
                  Text(l10n.aboutAlchronosPart2),
                  Text(l10n.aboutAlchronosPart3),
                  Text(l10n.aboutAlchronosPart4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
