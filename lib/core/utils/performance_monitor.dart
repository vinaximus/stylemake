import 'package:flutter/foundation.dart';

/// Utility for monitoring and measuring performance of operations
class PerformanceMonitor {
  PerformanceMonitor._();

  static PerformanceMonitor? _instance;
  static PerformanceMonitor get instance {
    _instance ??= PerformanceMonitor._();
    return _instance!;
  }

  // Store metrics: operation -> list of durations
  final Map<String, List<int>> _metrics = {};

  /// Measure and log operation duration
  Future<T> measure<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    final stopwatch = Stopwatch()..start();

    try {
      final result = await operation();
      stopwatch.stop();

      final durationMs = stopwatch.elapsedMilliseconds;
      _recordMetric(operationName, durationMs);

      debugPrint('⏱️ $operationName: ${durationMs}ms');

      return result;
    } catch (e) {
      stopwatch.stop();
      final durationMs = stopwatch.elapsedMilliseconds;
      _recordMetric(operationName, durationMs);

      debugPrint('⏱️ $operationName: ${durationMs}ms (FAILED)');
      rethrow;
    }
  }

  /// Measure synchronous operation
  T measureSync<T>(String operationName, T Function() operation) {
    final stopwatch = Stopwatch()..start();

    try {
      final result = operation();
      stopwatch.stop();

      final durationMs = stopwatch.elapsedMilliseconds;
      _recordMetric(operationName, durationMs);

      debugPrint('⏱️ $operationName: ${durationMs}ms');

      return result;
    } catch (e) {
      stopwatch.stop();
      final durationMs = stopwatch.elapsedMilliseconds;
      _recordMetric(operationName, durationMs);

      debugPrint('⏱️ $operationName: ${durationMs}ms (FAILED)');
      rethrow;
    }
  }

  /// Record a metric
  void _recordMetric(String operationName, int durationMs) {
    if (!_metrics.containsKey(operationName)) {
      _metrics[operationName] = [];
    }
    _metrics[operationName]!.add(durationMs);

    // Keep only last 100 measurements to avoid memory bloat
    if (_metrics[operationName]!.length > 100) {
      _metrics[operationName]!.removeAt(0);
    }
  }

  /// Get average duration for an operation
  double? getAverageDuration(String operationName) {
    final durations = _metrics[operationName];
    if (durations == null || durations.isEmpty) return null;

    final sum = durations.reduce((a, b) => a + b);
    return sum / durations.length;
  }

  /// Get minimum duration for an operation
  int? getMinDuration(String operationName) {
    final durations = _metrics[operationName];
    if (durations == null || durations.isEmpty) return null;

    return durations.reduce((a, b) => a < b ? a : b);
  }

  /// Get maximum duration for an operation
  int? getMaxDuration(String operationName) {
    final durations = _metrics[operationName];
    if (durations == null || durations.isEmpty) return null;

    return durations.reduce((a, b) => a > b ? a : b);
  }

  /// Get all metrics
  Map<String, PerformanceMetric> getAllMetrics() {
    final result = <String, PerformanceMetric>{};

    for (final entry in _metrics.entries) {
      final operationName = entry.key;
      final durations = entry.value;

      if (durations.isEmpty) continue;

      result[operationName] = PerformanceMetric(
        operationName: operationName,
        averageDurationMs: getAverageDuration(operationName)!,
        minDurationMs: getMinDuration(operationName)!,
        maxDurationMs: getMaxDuration(operationName)!,
        measurementCount: durations.length,
      );
    }

    return result;
  }

  /// Clear all metrics
  void clearMetrics() {
    _metrics.clear();
    debugPrint('🗑️ Performance metrics cleared');
  }

  /// Clear metrics for a specific operation
  void clearMetricsFor(String operationName) {
    _metrics.remove(operationName);
    debugPrint('🗑️ Metrics cleared for: $operationName');
  }

  /// Get performance report as string
  String getPerformanceReport() {
    final metrics = getAllMetrics();

    if (metrics.isEmpty) {
      return 'No performance metrics available';
    }

    final buffer = StringBuffer();
    buffer.writeln('=== Performance Report ===');
    buffer.writeln('Generated: ${DateTime.now().toIso8601String()}');
    buffer.writeln('\n');

    // Sort by operation name
    final sortedKeys = metrics.keys.toList()..sort();

    for (final key in sortedKeys) {
      final metric = metrics[key]!;
      buffer.writeln('${metric.operationName}:');
      buffer.writeln(
        '  Average: ${metric.averageDurationMs.toStringAsFixed(1)}ms',
      );
      buffer.writeln('  Min: ${metric.minDurationMs}ms');
      buffer.writeln('  Max: ${metric.maxDurationMs}ms');
      buffer.writeln('  Samples: ${metric.measurementCount}');
      buffer.writeln('');
    }

    buffer.writeln('=========================');

    return buffer.toString();
  }
}

/// Performance metric data class
class PerformanceMetric {
  final String operationName;
  final double averageDurationMs;
  final int minDurationMs;
  final int maxDurationMs;
  final int measurementCount;

  PerformanceMetric({
    required this.operationName,
    required this.averageDurationMs,
    required this.minDurationMs,
    required this.maxDurationMs,
    required this.measurementCount,
  });

  /// Check if operation meets performance target (2 seconds for lists)
  bool meetsTarget({int targetMs = 2000}) {
    return averageDurationMs <= targetMs;
  }

  @override
  String toString() {
    return 'PerformanceMetric($operationName: avg=${averageDurationMs.toStringAsFixed(1)}ms, min=${minDurationMs}ms, max=${maxDurationMs}ms, count=$measurementCount)';
  }
}
