import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alchronos/home/cubit/home_cubit.dart';

class HomeStartView extends StatelessWidget {
  const HomeStartView({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<HomeCubit>(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            key: Key('drinkIcon'),
            Icons.emoji_food_beverage,
            size: 60,
          ),
          const SizedBox(
            height: 16,
          ),
          ElevatedButton(
            key: const Key('drinkButton'),
            onPressed: () async => await cubit.start(),
            child: const Text(
              'Drink!',
              style: TextStyle(fontSize: 36),
            ),
          ),
        ],
      ),
    );
  }
}
