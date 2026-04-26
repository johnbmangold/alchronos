import 'dart:async';

import 'package:alchronos/infrastructure/services/logger_provider.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';

final performanceServiceProvider = Provider<PerformanceService>((ref) {
  return PerformanceService(ref.watch(loggerProvider));
});

class PerformanceService {
  PerformanceService(this._logger);

  final Logger _logger;
  final Map<String, DateTime> _startTimes = {};
  final Map<String, int> _eventCounts = {};

  /// Start timing an operation
  void startTiming(String operation) {
    _startTimes[operation] = DateTime.now();
  }

  /// End timing an operation and log the duration
  void endTiming(String operation) {
    final startTime = _startTimes.remove(operation);
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime);
      _logPerformance(operation, duration);
    }
  }

  /// Track an event occurrence
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

  /// Track timer-related events
  void trackTimerEvent(String event, {int? duration, bool? isPaused}) {
    final parameters = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
    };

    if (duration != null) parameters['duration'] = duration;
    if (isPaused != null) parameters['isPaused'] = isPaused;

    trackEvent('timer_$event', parameters: parameters);
  }

  /// Track user interaction events
  void trackUserInteraction(String action, {String? screen}) {
    final parameters = <String, dynamic>{
      'action': action,
      'timestamp': DateTime.now().toIso8601String(),
    };

    if (screen != null) parameters['screen'] = screen;

    trackEvent('user_interaction', parameters: parameters);
  }

  /// Track app performance metrics
  void trackAppPerformance(String metric, dynamic value) {
    final parameters = <String, dynamic>{
      'metric': metric,
      'value': value,
      'timestamp': DateTime.now().toIso8601String(),
    };

    trackEvent('app_performance', parameters: parameters);
  }

  /// Get event statistics
  Map<String, int> getEventStats() {
    return Map.from(_eventCounts);
  }

  /// Log performance metrics
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

  /// Track memory usage
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
