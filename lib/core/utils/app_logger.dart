import 'package:flutter/foundation.dart';

/// Log level enum for different severity levels
enum LogLevel {
  debug,
  info,
  warning,
  error,
  success,
}

/// Enhanced logger utility for readable and intuitive logging
///
/// **Color Support:**
/// - Colors work in terminals (when running `flutter run` from command line)
/// - Colors do NOT work in IDE debug consoles (VS Code, Android Studio, etc.)
/// - To force enable colors: `AppLogger.enableColors = true`
/// - To force disable colors: `AppLogger.enableColors = false`
/// - Auto-detection is enabled by default
class AppLogger {
  // ANSI color codes
  static const String _reset = '\x1B[0m';
  static const String _red = '\x1B[31m';
  static const String _green = '\x1B[32m';
  static const String _yellow = '\x1B[33m';
  static const String _blue = '\x1B[34m';
  static const String _magenta = '\x1B[35m';
  static const String _cyan = '\x1B[36m';
  static const String _white = '\x1B[37m';
  static const String _gray = '\x1B[90m';

  // Cache color support detection
  static bool? _colorSupportCache;

  /// Enable or disable colors (null = auto-detect)
  ///
  /// Set to `true` to force enable colors (useful for terminals)
  /// Set to `false` to force disable colors (useful for IDE debug console)
  /// Leave as `null` for auto-detection
  ///
  /// Example:
  /// ```dart
  /// AppLogger.enableColors = true; // Force enable colors
  /// ```
  static bool? enableColors;

  static String get _separator => '─' * 80;
  static String get _doubleSeparator => '═' * 80;

  /// Check if the current environment supports ANSI color codes
  ///
  /// Note: Flutter's debug console doesn't support ANSI colors.
  /// Colors only work when running `flutter run` from an actual terminal.
  /// To enable colors in terminal: `AppLogger.enableColors = true`
  static bool _supportsColors() {
    // If explicitly set, use that value
    if (enableColors != null) {
      return enableColors!;
    }

    // Use cached value if available
    if (_colorSupportCache != null) {
      return _colorSupportCache!;
    }

    // Default to false - colors must be explicitly enabled
    // This prevents escape codes from showing in IDE debug consoles
    _colorSupportCache = false;
    return false;

    // Note: Auto-detection is disabled by default because Flutter's
    // stdout.supportsAnsiEscapes can return true even in IDE consoles
    // that don't actually render the colors. Users should explicitly
    // enable colors when running from terminal: AppLogger.enableColors = true
  }

  /// Get color code if colors are supported, otherwise return empty string
  static String _getColorCode(String colorCode) {
    return _supportsColors() ? colorCode : '';
  }

  /// Log a debug message
  static void debug(String message, {String? tag, Object? data}) {
    _log(LogLevel.debug, message, tag: tag, data: data);
  }

  /// Log an info message
  static void info(String message, {String? tag, Object? data}) {
    _log(LogLevel.info, message, tag: tag, data: data);
  }

  /// Log a warning message
  static void warning(String message, {String? tag, Object? data}) {
    _log(LogLevel.warning, message, tag: tag, data: data);
  }

  /// Log an error message
  static void error(String message,
      {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.error, message,
        tag: tag, data: error, stackTrace: stackTrace);
  }

  /// Log a success message
  static void success(String message, {String? tag, Object? data}) {
    _log(LogLevel.success, message, tag: tag, data: data);
  }

  /// Internal logging method
  static void _log(
    LogLevel level,
    String message, {
    String? tag,
    Object? data,
    StackTrace? stackTrace,
  }) {
    if (kReleaseMode && level == LogLevel.debug) {
      return; // Skip debug logs in release mode
    }

    final colorCode = _getColor(level);
    final color = _getColorCode(colorCode);
    final reset = _getColorCode(_reset);
    final gray = _getColorCode(_gray);
    final red = _getColorCode(_red);

    final timestamp = DateTime.now().toIso8601String();
    final emoji = _getEmoji(level);
    final levelName = level.name.toUpperCase().padRight(7);
    final tagSection = tag != null ? '[$tag] ' : '';

    // Build the log message with colors
    final buffer = StringBuffer();

    // Header with colored separator
    buffer.writeln('$color$_doubleSeparator$reset');
    buffer.writeln(
        '$color$emoji $levelName │$reset $tagSection$color$message$reset');
    buffer.writeln('$color$_separator$reset');

    // Timestamp (gray)
    buffer.writeln('$gray⏰ Time: $timestamp$reset');

    // Data section
    if (data != null) {
      buffer.writeln('$gray📦 Data:$reset');
      if (data is Map) {
        _formatMap(buffer, data, indent: 2, color: color, reset: reset);
      } else if (data is List) {
        _formatList(buffer, data, indent: 2, color: color, reset: reset);
      } else {
        buffer.writeln('$color   ${data.toString()}$reset');
      }
    }

    // Stack trace for errors (red)
    if (stackTrace != null) {
      buffer.writeln('$red📚 Stack Trace:$reset');
      buffer.writeln(
          '$red${stackTrace.toString().split('\n').take(10).join('\n')}$reset');
    }

    buffer.writeln('$color$_doubleSeparator$reset\n');

    // Output to console
    // Use print() when colors are enabled (works in terminals)
    // Use debugPrint() when colors are disabled (works in IDE debug console)
    if (_supportsColors()) {
      print(buffer.toString());
    } else {
      debugPrint(buffer.toString());
    }
  }

  /// Get emoji for log level
  static String _getEmoji(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '🔍';
      case LogLevel.info:
        return 'ℹ️';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.error:
        return '❌';
      case LogLevel.success:
        return '✅';
    }
  }

  /// Get ANSI color code string for log level (returns the code, not the formatted version)
  static String _getColor(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return _magenta;
      case LogLevel.info:
        return _blue;
      case LogLevel.warning:
        return _yellow;
      case LogLevel.error:
        return _red;
      case LogLevel.success:
        return _green;
    }
  }

  /// Format map data for readable output
  static void _formatMap(StringBuffer buffer, Map map,
      {int indent = 0, String color = '', String reset = ''}) {
    final indentStr = ' ' * indent;
    map.forEach((key, value) {
      if (value is Map) {
        buffer.writeln('$indentStr$color$key:$reset');
        _formatMap(buffer, value,
            indent: indent + 2, color: color, reset: reset);
      } else if (value is List) {
        buffer.writeln('$indentStr$color$key:$reset');
        _formatList(buffer, value,
            indent: indent + 2, color: color, reset: reset);
      } else {
        buffer.writeln('$indentStr$color$key:$reset $value');
      }
    });
  }

  /// Format list data for readable output
  static void _formatList(StringBuffer buffer, List list,
      {int indent = 0, String color = '', String reset = ''}) {
    final indentStr = ' ' * indent;
    for (var i = 0; i < list.length; i++) {
      final item = list[i];
      if (item is Map) {
        buffer.writeln('$indentStr$color[$i]:$reset');
        _formatMap(buffer, item,
            indent: indent + 2, color: color, reset: reset);
      } else if (item is List) {
        buffer.writeln('$indentStr$color[$i]:$reset');
        _formatList(buffer, item,
            indent: indent + 2, color: color, reset: reset);
      } else {
        buffer.writeln('$indentStr$color[$i]:$reset $item');
      }
    }
  }

  /// Log API request in a readable format
  static void logApiRequest({
    required String method,
    required String url,
    Map<String, dynamic>? headers,
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) {
    final buffer = StringBuffer();
    final colorCode = _cyan;
    final color = _getColorCode(colorCode);
    final reset = _getColorCode(_reset);
    final white = _getColorCode(_white);

    buffer.writeln('$color$_doubleSeparator$reset');
    buffer.writeln('$color🌐 API REQUEST$reset');
    buffer.writeln('$color$_separator$reset');
    buffer.writeln('$white📤 Method:$reset $color$method$reset');
    buffer.writeln('$white🔗 URL:$reset $color$url$reset');

    if (queryParameters != null && queryParameters.isNotEmpty) {
      buffer.writeln('$white🔍 Query Parameters:$reset');
      _formatMap(buffer, queryParameters,
          indent: 2, color: color, reset: reset);
    }

    if (headers != null && headers.isNotEmpty) {
      // Filter sensitive headers
      final safeHeaders = Map<String, dynamic>.from(headers);
      if (safeHeaders.containsKey('Authorization')) {
        final auth = safeHeaders['Authorization'] as String?;
        if (auth != null && auth.length > 20) {
          safeHeaders['Authorization'] = '${auth.substring(0, 20)}...';
        }
      }
      buffer.writeln('$white📋 Headers:$reset');
      _formatMap(buffer, safeHeaders, indent: 2, color: color, reset: reset);
    }

    if (data != null) {
      buffer.writeln('$white📦 Request Body:$reset');
      if (data is Map) {
        _formatMap(buffer, data, indent: 2, color: color, reset: reset);
      } else if (data is List) {
        _formatList(buffer, data, indent: 2, color: color, reset: reset);
      } else {
        buffer.writeln('$color   $data$reset');
      }
    }

    buffer.writeln('$color$_doubleSeparator$reset\n');
    // Use print() when colors are enabled, debugPrint() when disabled
    if (_supportsColors()) {
      print(buffer.toString());
    } else {
      debugPrint(buffer.toString());
    }
  }

  /// Log API response in a readable format
  static void logApiResponse({
    required String method,
    required String url,
    required int? statusCode,
    Map<String, dynamic>? headers,
    dynamic data,
    String? errorMessage,
  }) {
    final buffer = StringBuffer();
    String colorCode;
    String title;

    if (statusCode != null && statusCode >= 200 && statusCode < 300) {
      colorCode = _green;
      title = '✅ API RESPONSE (Success)';
    } else if (statusCode != null && statusCode >= 400) {
      colorCode = _red;
      title = '❌ API RESPONSE (Error)';
    } else {
      colorCode = _cyan;
      title = '📥 API RESPONSE';
    }

    final color = _getColorCode(colorCode);
    final reset = _getColorCode(_reset);
    final white = _getColorCode(_white);
    final red = _getColorCode(_red);

    buffer.writeln('$color$_doubleSeparator$reset');
    buffer.writeln('$color$title$reset');
    buffer.writeln('$color$_separator$reset');
    buffer.writeln('$white📤 Method:$reset $color$method$reset');
    buffer.writeln('$white🔗 URL:$reset $color$url$reset');

    if (statusCode != null) {
      final statusColorCode = statusCode >= 200 && statusCode < 300
          ? _green
          : statusCode >= 400
              ? _red
              : _yellow;
      final statusColor = _getColorCode(statusColorCode);
      final statusEmoji = statusCode >= 200 && statusCode < 300
          ? '✅'
          : statusCode >= 400
              ? '❌'
              : '⚠️';
      buffer.writeln('$statusColor$statusEmoji Status Code: $statusCode$reset');
    }

    if (errorMessage != null) {
      buffer.writeln('$red❌ Error: $errorMessage$reset');
    }

    if (headers != null && headers.isNotEmpty) {
      buffer.writeln('$white📋 Response Headers:$reset');
      _formatMap(buffer, headers, indent: 2, color: color, reset: reset);
    }

    if (data != null) {
      buffer.writeln('$white📦 Response Body:$reset');
      if (data is Map) {
        _formatMap(buffer, data, indent: 2, color: color, reset: reset);
      } else if (data is List) {
        _formatList(buffer, data, indent: 2, color: color, reset: reset);
      } else {
        buffer.writeln('$color   $data$reset');
      }
    }

    buffer.writeln('$color$_doubleSeparator$reset\n');
    // Use print() when colors are enabled, debugPrint() when disabled
    if (_supportsColors()) {
      print(buffer.toString());
    } else {
      debugPrint(buffer.toString());
    }
  }
}
