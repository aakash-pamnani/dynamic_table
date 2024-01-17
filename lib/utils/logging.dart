import 'package:logging/logging.dart';

abstract class LoggerNameBase {
  String get loggerName;
}

extension Logging on List<LoggerNameBase> {
  void info(String Function () getMessage) {
    this.forEach((loggerName) { final log = Logger(loggerName.loggerName); if (log.isLoggable(Level.INFO)) log.info(getMessage()); });
  }
}
