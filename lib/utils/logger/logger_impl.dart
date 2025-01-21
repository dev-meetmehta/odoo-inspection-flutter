import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'logger_repository.dart';

class LoggerImpl implements LoggerRepository {
  LoggerImpl({
    required this.logger,
  });
  Logger logger;

  /// Info log
  @override
  void traceLogInfo(String message) => logger.i(message);

  /// Warning log
  @override
  void traceLogWarning(String message) => logger.w(message);

  /// Debug log
  @override
  void traceLogDebug(String message) => logger.d(message);

  /// Verbose log
  @override
  void traceLogVerbose(String message) => logger.v(message);
}
