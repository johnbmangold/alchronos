import 'package:alchronos/app_database.dart';
import 'package:flutter/foundation.dart';

@immutable
sealed class HomeState {}

class HomeInitial extends HomeState {}

class HomeStart extends HomeState {}

class HomeError extends HomeState {
  HomeError(this.message);

  final String message;
}

class HomeRunning extends HomeState {
  HomeRunning({
    required this.partialRunData,
    required this.totalDurationInSeconds,
    this.isPaused = false,
    this.pausedAt,
  });

  final PartialRunData partialRunData;
  final int totalDurationInSeconds;
  final bool isPaused;
  final DateTime? pausedAt;

  HomeRunning copyWith({
    PartialRunData? partialRunData,
    int? totalDurationInSeconds,
    bool? isPaused,
    DateTime? pausedAt,
  }) {
    return HomeRunning(
      partialRunData: partialRunData ?? this.partialRunData,
      totalDurationInSeconds:
          totalDurationInSeconds ?? this.totalDurationInSeconds,
      isPaused: isPaused ?? this.isPaused,
      pausedAt: pausedAt ?? this.pausedAt,
    );
  }
}
