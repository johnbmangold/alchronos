import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_app/home/cubit/home_cubit.dart';

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
            Icons.emoji_food_beverage,
            size: 60,
          ),
          ElevatedButton(
            onPressed: () => cubit.start(),
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
