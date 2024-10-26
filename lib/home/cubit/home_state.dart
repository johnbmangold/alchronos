part of 'home_cubit.dart';

@immutable
abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeStart extends HomeState {}

class HomeRunning extends HomeState {
  HomeRunning({
    required this.partialRunData,
    required this.totalDurationInSeconds,
  });

  final PartialRunData partialRunData;
  final int totalDurationInSeconds;
}
