import 'package:alchronos/core/errors/app_exceptions.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Global error handler for the application
class ErrorHandler {
  static final Logger _logger = Logger();

  /// Handle and log errors throughout the application
  static Future<void> handleError(
    dynamic error,
    StackTrace? stackTrace, {
    String? context,
    bool reportToCrashlytics = true,
  }) async {
    final errorMessage = _getErrorMessage(error);
    final contextMessage = context != null ? 'Context: $context' : '';

    // Log error locally
    _logger.e(
      'Error occurred: $errorMessage\n$contextMessage',
      error: error,
      stackTrace: stackTrace,
    );

    // Report to Firebase Crashlytics in production
    if (reportToCrashlytics && !kDebugMode) {
      if (error is AppException) {
        await FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          reason: 'AppException: ${error.message}',
        );
      } else {
        await FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          reason: 'Unexpected error: $errorMessage',
        );
      }
    }
  }

  /// Get a user-friendly error message
  static String _getErrorMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    } else if (error is Exception) {
      return error.toString();
    } else {
      return 'An unexpected error occurred';
    }
  }

  /// Get a user-friendly error message for UI display
  static String getUserFriendlyMessage(dynamic error) {
    if (error is DatabaseException) {
      return 'Failed to save data. Please try again.';
    } else if (error is StorageException) {
      return 'Failed to save preferences. Please try again.';
    } else if (error is TimerException) {
      return 'Timer error occurred. Please restart the timer.';
    } else if (error is NotificationException) {
      return 'Notification error occurred. Please check your settings.';
    } else if (error is NetworkException) {
      return 'Network error. Please check your connection.';
    } else if (error is ValidationException) {
      return error.message;
    } else {
      return 'Something went wrong. Please try again.';
    }
  }
}
