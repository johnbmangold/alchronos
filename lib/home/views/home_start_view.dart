import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alchronos/home/cubit/home_cubit.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeStartView extends StatelessWidget {
  const HomeStartView({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<HomeCubit>(context);
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            key: const Key('drinkIcon'),
            Icons.emoji_food_beverage,
            size: 60,
            semanticLabel: l10n.drinkIconSemanticsLabel,
          ),
          const SizedBox(
            height: 16,
          ),
          ElevatedButton(
            key: const Key('drinkButton'),
            onPressed: () async => await cubit.start(),
            child: Text(
              l10n.drinkButtonText,
              style: const TextStyle(fontSize: 36),
              semanticsLabel: l10n.drinkButtonSemanticsLabel,
            ),
          ),
        ],
      ),
    );
  }
}
