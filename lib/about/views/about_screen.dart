import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.aboutAlchronosTitle),
        centerTitle: true,
        leading: InkWell(
          child: const Icon(Icons.arrow_back),
          onTap: () {
            context.goNamed('home');
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            TextButton(
              onPressed: () {},
              child: Text(
                l10n.aboutAlchronos,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
