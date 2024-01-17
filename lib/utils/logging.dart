import 'package:logging/logging.dart';

abstract class LoggerNameBase {
  String get name;
}

extension Logging on List<LoggerNameBase> {
  void info(String Function () getMessage) {
    this.forEach((loggerName) { final log = Logger(loggerName.name); if (log.isLoggable(Level.INFO)) log.info(getMessage()); });
  }
}
