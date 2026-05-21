import 'package:talker_flutter/talker_flutter.dart';

/// Thin wrapper around Talker with stable logging methods.
final class AppLogger {
  AppLogger(this._talker);

  final Talker _talker;

  /// Writes a verbose log line.
  void verbose(String message) => _talker.verbose(message);

  /// Writes a debug log line.
  void debug(String message) => _talker.debug(message);

  /// Writes an info log line.
  void info(String message) => _talker.info(message);

  /// Writes a warning log line.
  void warning(String message) => _talker.warning(message);

  /// Writes an error log line.
  void error(
    Object error, {
    String? message,
    StackTrace? stackTrace,
  }) {
    _talker.error(message ?? error.toString(), error, stackTrace);
  }
}

/// Global logger instance.
final AppLogger logger = AppLogger(
  TalkerFlutter.init(
    settings: TalkerSettings(
      enabled: true,
      useConsoleLogs: true,
    ),
  ),
);
