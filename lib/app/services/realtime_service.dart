import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:stylemake/app/services/supabase_service.dart';

/// Service for managing Supabase Realtime subscriptions
class RealtimeService {
  RealtimeService._();

  static RealtimeService? _instance;
  static RealtimeService get instance {
    _instance ??= RealtimeService._();
    return _instance!;
  }

  final Map<String, RealtimeChannel> _channels = {};
  final Map<String, StreamController<RealtimeUpdate>> _controllers = {};

  /// Get the Supabase client
  SupabaseClient get _client => SupabaseService.instance.client;

  /// Default company ID for filtering
  static const String defaultCompanyId = '00000000-0000-0000-0000-000000000000';

  /// Subscribe to changes on a table
  /// Returns a stream of updates for the specified table
  Stream<RealtimeUpdate> subscribeToTable({
    required String table,
    PostgresChangeFilter? filter,
  }) {
    final channelName = filter != null ? '$table:${filter.toString()}' : table;

    // Return existing stream if already subscribed
    if (_controllers.containsKey(channelName)) {
      debugPrint('✓ Already subscribed to $channelName');
      return _controllers[channelName]!.stream;
    }

    debugPrint('📡 Subscribing to realtime updates for $channelName');

    // Create a new stream controller
    final controller = StreamController<RealtimeUpdate>.broadcast();
    _controllers[channelName] = controller;

    try {
      // Create channel
      final channel = _client.channel(channelName);

      // Listen to all events (INSERT, UPDATE, DELETE) on the table
      channel.onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: table,
        filter: filter,
        callback: (payload) {
          debugPrint(
            '📨 Realtime event received on $table: ${payload.eventType}',
          );

          final update = RealtimeUpdate(
            table: table,
            eventType: payload.eventType.name,
            oldRecord: payload.oldRecord,
            newRecord: payload.newRecord,
          );

          if (!controller.isClosed) {
            controller.add(update);
          }
        },
      );

      // Subscribe to the channel
      channel.subscribe((status, error) {
        if (status == RealtimeSubscribeStatus.subscribed) {
          debugPrint('✅ Successfully subscribed to $channelName');
        } else if (status == RealtimeSubscribeStatus.timedOut) {
          debugPrint('⏱️ Subscription timed out for $channelName');
          controller.addError('Subscription timed out');
        } else if (status == RealtimeSubscribeStatus.channelError) {
          debugPrint('❌ Channel error for $channelName: $error');
          controller.addError(error ?? 'Channel error');
        }
      });

      _channels[channelName] = channel;
    } catch (e, stackTrace) {
      debugPrint('❌ Failed to subscribe to $channelName: $e');
      debugPrint('Stack trace: $stackTrace');
      controller.addError(e);
    }

    return controller.stream;
  }

  /// Subscribe to a table filtered by company_id
  Stream<RealtimeUpdate> subscribeToCompanyTable({
    required String table,
    String? companyId,
  }) {
    final id = companyId ?? defaultCompanyId;
    return subscribeToTable(
      table: table,
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'company_id',
        value: id,
      ),
    );
  }

  /// Unsubscribe from a table
  Future<void> unsubscribeFromTable(
    String table, {
    PostgresChangeFilter? filter,
  }) async {
    final channelName = filter != null ? '$table:${filter.toString()}' : table;

    debugPrint('🔌 Unsubscribing from $channelName');

    // Close stream controller
    if (_controllers.containsKey(channelName)) {
      await _controllers[channelName]!.close();
      _controllers.remove(channelName);
    }

    // Unsubscribe from channel
    if (_channels.containsKey(channelName)) {
      await _channels[channelName]!.unsubscribe();
      _channels.remove(channelName);
    }
  }

  /// Unsubscribe from company table
  Future<void> unsubscribeFromCompanyTable({
    required String table,
    String? companyId,
  }) async {
    final id = companyId ?? defaultCompanyId;
    await unsubscribeFromTable(
      table,
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'company_id',
        value: id,
      ),
    );
  }

  /// Unsubscribe from all tables
  Future<void> unsubscribeAll() async {
    debugPrint('🔌 Unsubscribing from all channels');

    // Close all controllers
    for (final controller in _controllers.values) {
      await controller.close();
    }
    _controllers.clear();

    // Unsubscribe from all channels
    for (final channel in _channels.values) {
      await channel.unsubscribe();
    }
    _channels.clear();
  }

  /// Get active subscriptions count
  int get activeSubscriptionsCount => _channels.length;

  /// Check if subscribed to a table
  bool isSubscribedTo(String table, {PostgresChangeFilter? filter}) {
    final channelName = filter != null ? '$table:${filter.toString()}' : table;
    return _channels.containsKey(channelName);
  }

  /// Dispose of the service
  Future<void> dispose() async {
    await unsubscribeAll();
  }
}

/// Represents a realtime update event
class RealtimeUpdate {
  final String table;
  final String eventType; // 'INSERT', 'UPDATE', 'DELETE'
  final Map<String, dynamic>? oldRecord;
  final Map<String, dynamic>? newRecord;

  RealtimeUpdate({
    required this.table,
    required this.eventType,
    this.oldRecord,
    this.newRecord,
  });

  bool get isInsert => eventType == 'INSERT';
  bool get isUpdate => eventType == 'UPDATE';
  bool get isDelete => eventType == 'DELETE';

  @override
  String toString() {
    return 'RealtimeUpdate(table: $table, event: $eventType)';
  }
}
