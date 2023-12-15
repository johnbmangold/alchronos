import 'package:alchronos/main.dart';
import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final Color color = Theme.of(context).extension<CustomColors>()!.brand!;
    return SafeArea(
      child: Center(
        key: const Key('loadingView'),
        child: AvatarGlow(
          glowColor: color,
          duration: const Duration(milliseconds: 1000),
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
    );
  }
}
