/// Reusable error handling utilities for consistent error management
class ErrorHandler {
  ErrorHandler._(); // Private constructor

  /// Safely executes an async function with error handling
  /// Returns the result or null if an error occurs
  static Future<T?> safeExecute<T>(
    Future<T> Function() action, {
    T? defaultValue,
    void Function(Object error)? onError,
  }) async {
    try {
      return await action();
    } catch (e) {
      onError?.call(e);
      return defaultValue;
    }
  }

  /// Safely executes a sync function with error handling
  /// Returns the result or null if an error occurs
  static T? safeExecuteSync<T>(
    T Function() action, {
    T? defaultValue,
    void Function(Object error)? onError,
  }) {
    try {
      return action();
    } catch (e) {
      onError?.call(e);
      return defaultValue;
    }
  }

  /// Executes an async function and ignores errors silently
  static Future<void> silentExecute(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {
      // Silently ignore errors
    }
  }

  /// Executes a sync function and ignores errors silently
  static void silentExecuteSync(void Function() action) {
    try {
      action();
    } catch (_) {
      // Silently ignore errors
    }
  }

  /// Executes multiple async operations in parallel with error handling
  /// Continues even if some operations fail
  static Future<List<T?>> safeExecuteAll<T>(
    List<Future<T> Function()> actions, {
    void Function(int index, Object error)? onError,
  }) async {
    final results = await Future.wait(
      actions.asMap().entries.map((entry) async {
        try {
          return await entry.value();
        } catch (e) {
          onError?.call(entry.key, e);
          return null;
        }
      }),
      eagerError: false,
    );
    return results;
  }
}
