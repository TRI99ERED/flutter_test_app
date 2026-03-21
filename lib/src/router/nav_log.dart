import 'dart:developer' as dev;

/// Lightweight navigation logger.
///
/// All output goes through `dart:developer` `log` with the name `Navigator`,
/// so it shows up in DevTools and is easy to filter.
abstract final class NavLog {
  static const _name = 'Navigator';

  /// Log a navigation event with an optional context map.
  static void d(String message, [Map<String, Object?>? context]) {
    dev.log(_format(message, context), name: _name);
  }

  /// Log a warning.
  static void w(String message, [Map<String, Object?>? context]) {
    dev.log(_format(message, context), name: _name, level: 900);
  }

  /// Log an error.
  static void e(String message, [Object? error, StackTrace? stackTrace]) {
    dev.log(message, name: _name, level: 1000, error: error, stackTrace: stackTrace);
  }

  static String _format(String message, Map<String, Object?>? context) {
    if (context == null || context.isEmpty) return message;
    final params = context.entries
        .map((e) => '${e.key}: ${e.value}')
        .join(', ');
    return '$message ($params)';
  }
}
