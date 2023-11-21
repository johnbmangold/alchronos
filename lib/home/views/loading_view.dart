import 'package:alchronos/main.dart';
import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final Color color = Theme.of(context).extension<CustomColors>()!.brand!;
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      label: l10n.loadingScreenSemanticsLabel,
      child: SafeArea(
        child: Center(
          key: const Key('loadingView'),
          child: AvatarGlow(
            endRadius: 150,
            glowColor: color,
            duration: const Duration(milliseconds: 1000),
            repeatPauseDuration: const Duration(milliseconds: 5),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
              child: const Center(
                child: Icon(Icons.emoji_food_beverage),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
