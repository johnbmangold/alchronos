import 'dart:async';

import 'package:alchronos/infrastructure/services/logger_provider.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';

/// Provider for the [PerformanceService].
final performanceServiceProvider = Provider<PerformanceService>((ref) {
  return PerformanceService(ref.watch(loggerProvider));
});

/// Service responsible for tracking application performance and analytics.
class PerformanceService {
  /// Creates a [PerformanceService] using the provided [_logger].
  PerformanceService(this._logger);

  final Logger _logger;
  final Map<String, DateTime> _startTimes = {};
  final Map<String, int> _eventCounts = {};

  /// Starts timing an operation by [operation] name.
  void startTiming(String operation) {
    _startTimes[operation] = DateTime.now();
  }

  /// Ends timing an operation by [operation] name and logs the duration.
  void endTiming(String operation) {
    final startTime = _startTimes.remove(operation);
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime);
      _logPerformance(operation, duration);
    }
  }

  /// Tracks a generic event occurrence by [eventName] with optional
  /// [parameters].
  void trackEvent(String eventName, {Map<String, dynamic>? parameters}) {
    _eventCounts[eventName] = (_eventCounts[eventName] ?? 0) + 1;

    _logger.i('Event tracked: $eventName', error: parameters);

    // Report to Firebase Crashlytics in production
    if (!kDebugMode) {
      unawaited(FirebaseCrashlytics.instance.log('Event: $eventName'));
      if (parameters != null) {
        unawaited(
          FirebaseCrashlytics.instance
              .setCustomKey('event_$eventName', parameters.toString()),
        );
      }
    }
  }

  /// Tracks timer-related events.
  void trackTimerEvent(String event, {int? duration, bool? isPaused}) {
    final parameters = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
    };

    if (duration != null) parameters['duration'] = duration;
    if (isPaused != null) parameters['isPaused'] = isPaused;

    trackEvent('timer_$event', parameters: parameters);
  }

  /// Tracks user interaction events.
  void trackUserInteraction(String action, {String? screen}) {
    final parameters = <String, dynamic>{
      'action': action,
      'timestamp': DateTime.now().toIso8601String(),
    };

    if (screen != null) parameters['screen'] = screen;

    trackEvent('user_interaction', parameters: parameters);
  }

  /// Tracks app performance metrics.
  void trackAppPerformance(String metric, dynamic value) {
    final parameters = <String, dynamic>{
      'metric': metric,
      'value': value,
      'timestamp': DateTime.now().toIso8601String(),
    };

    trackEvent('app_performance', parameters: parameters);
  }

  /// Retrieves the current event statistics.
  Map<String, int> getEventStats() {
    return Map.from(_eventCounts);
  }

  /// Log performance metrics internally.
  void _logPerformance(String operation, Duration duration) {
    _logger.i('Performance: $operation took ${duration.inMilliseconds}ms');

    // Report to Firebase Crashlytics in production
    if (!kDebugMode) {
      unawaited(
        FirebaseCrashlytics.instance
            .log('Performance: $operation - ${duration.inMilliseconds}ms'),
      );
    }
  }

  /// Tracks the application's memory usage.
  void trackMemoryUsage() {
    // This is a simplified memory tracking
    // In a real app, you might use more sophisticated memory monitoring
    final memoryInfo = {
      'timestamp': DateTime.now().toIso8601String(),
      'event_count': _eventCounts.length,
      'active_timings': _startTimes.length,
    };

    trackEvent('memory_usage', parameters: memoryInfo);
  }
}
