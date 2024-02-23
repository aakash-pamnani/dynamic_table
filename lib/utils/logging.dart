import 'package:logging/logging.dart';

abstract class LoggerNameBase {
  String get loggerName;
}

extension Logging on List<LoggerNameBase> {
  void log(Level level, String Function () getMessage) {
    this.forEach((loggerName) { final log = Logger(loggerName.loggerName); if (log.isLoggable(level)) log.log(level, getMessage()); });
  }

  void info(String Function () getMessage) {
    final Level level = Level.INFO;
    log(level, getMessage);
  }

  void severe(String Function () getMessage) {
    final Level level = Level.SEVERE;
    log(level, getMessage);
  }

  Exception severeAndThrow(String Function () getMessage) {
    severe(getMessage);
    return Exception(getMessage());
  }
}
