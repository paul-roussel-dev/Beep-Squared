import 'dart:async';
import 'package:flutter/foundation.dart';

/// Performance utilities for optimizing app performance
class PerformanceUtils {
  PerformanceUtils._();

  /// Run a heavy computation in a separate isolate to avoid blocking the UI
  static Future<T> runInIsolate<T>(
    ComputeCallback<dynamic, T> callback,
    dynamic message,
  ) async {
    try {
      return await compute(callback, message);
    } catch (e) {
      debugPrint('Error running computation in isolate: $e');
      rethrow;
    }
  }

  /// Debounce function calls to reduce frequency
  static void debounce(
    String key,
    VoidCallback callback, {
    Duration delay = const Duration(milliseconds: 300),
  }) {
    _timers[key]?.cancel();
    _timers[key] = Timer(delay, callback);
  }

  /// Throttle function calls to limit frequency
  static void throttle(
    String key,
    VoidCallback callback, {
    Duration interval = const Duration(milliseconds: 100),
  }) {
    final now = DateTime.now();
    final lastCall = _lastCalls[key];
    
    if (lastCall == null || now.difference(lastCall) >= interval) {
      _lastCalls[key] = now;
      callback();
    }
  }

  /// Clear all cached timers and calls
  static void clearCache() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    _lastCalls.clear();
  }

  static final Map<String, Timer> _timers = {};
  static final Map<String, DateTime> _lastCalls = {};
}

/// Extensions for better performance
extension PerformanceExtensions on Duration {
  /// Check if duration is considered fast for UI operations
  bool get isFastEnoughForUI => inMilliseconds <= 16; // 60fps = ~16ms per frame
  
  /// Check if duration might cause frame drops
  bool get mightCauseFrameDrops => inMilliseconds > 16;
}

/// Memory usage utilities
class MemoryUtils {
  MemoryUtils._();

  /// Force garbage collection (use sparingly in debug mode only)
  static void forceGC() {
    if (kDebugMode) {
      // This is a hack and should only be used for debugging
      List.generate(1000000, (index) => index).clear();
    }
  }

  /// Log memory usage information
  static void logMemoryUsage(String context) {
    if (kDebugMode) {
      debugPrint('Memory check at $context: ${DateTime.now()}');
    }
  }
}
