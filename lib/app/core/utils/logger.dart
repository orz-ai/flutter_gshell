import 'package:logger/logger.dart';

class LoggerUtil {
  static late Logger _logger;
  
  static void init() {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        printTime: true,
      ),
    );
  }
  
  static void d(dynamic message) {
    _logger.d(message);
  }
  
  static void i(dynamic message) {
    _logger.i(message);
  }
  
  static void w(dynamic message) {
    _logger.w(message);
  }
  
  static void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (error != null) {
      _logger.e('$message: $error');
    } else {
      _logger.e(message);
    }
  }
} 