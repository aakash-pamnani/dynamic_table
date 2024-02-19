import 'package:dynamic_table/utils/logging.dart';

enum LoggingWidget implements LoggerNameBase {
  loggingFocus, loggingFailure, loggingKeyEvent;

  String get loggerName => this.name;
}
