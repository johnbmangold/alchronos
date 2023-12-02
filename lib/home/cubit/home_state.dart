part of 'home_cubit.dart';

@immutable
abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeStart extends HomeState {}

class HomeRunning extends HomeState {
  HomeRunning({required this.partialRun, required this.totalDurationInSeconds});

  final PartialRun partialRun;
  final int totalDurationInSeconds;
}
