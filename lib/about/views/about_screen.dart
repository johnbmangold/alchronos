import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Alchronos'),
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
            const Text('Buy Me a Coffee'),
            TextButton(
              onPressed: () {},
              child: const Text(
                'A long description of Alchronos that will be implemented with l10n',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
