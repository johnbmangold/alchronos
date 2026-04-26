import 'package:alchronos/app_database.dart';
import 'package:flutter/foundation.dart';

/// The base class for all states managed by the HomeNotifier.
@immutable
sealed class HomeState {}

/// The initial state when the application first loads.
class HomeInitial extends HomeState {}

/// The state indicating that the home screen is ready to start a timer.
class HomeStart extends HomeState {}

/// The state indicating that an error has occurred.
class HomeError extends HomeState {
  /// Creates a [HomeError] with the given error [message].
  HomeError(this.message);

  /// The error message.
  final String message;
}

/// The state indicating that a timer is currently running.
class HomeRunning extends HomeState {
  /// Creates a [HomeRunning] state with the ongoing [partialRunData] and
  /// [totalDurationInSeconds].
  HomeRunning({
    required this.partialRunData,
    required this.totalDurationInSeconds,
    this.isPaused = false,
    this.pausedAt,
  });

  /// Data describing the currently running timer session.
  final PartialRunData partialRunData;

  /// The initial total duration of the timer.
  final int totalDurationInSeconds;

  /// Whether the timer is currently paused.
  final bool isPaused;

  /// The timestamp when the timer was paused.
  final DateTime? pausedAt;

  /// Creates a copy of this state with the given fields replaced by
  /// the new values.
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
