import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';

/// Provider for a globally shared [Logger] instance.
final loggerProvider = Provider<Logger>((ref) {
  return Logger(printer: PrettyPrinter());
});
