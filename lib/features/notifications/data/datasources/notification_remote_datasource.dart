import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/notification_entity.dart';
import '../models/notification_model.dart';

abstract interface class NotificationRemoteDataSource {
  Future<List<NotificationEntity>> getNotifications(String userId);
  Future<void> markAsRead(String notificationId, String userId);
  Future<void> markAllAsRead(String userId);
  Stream<List<NotificationEntity>> watchNotifications(String userId);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final SupabaseClient _client;
  const NotificationRemoteDataSourceImpl(this._client);

  @override
  Future<List<NotificationEntity>> getNotifications(String userId) async {
    try {
      // Fetch notifications the user is entitled to see
      final notifs = await _client
          .from('notifications')
          .select()
          .or('target_type.eq.all,target_user_id.eq.$userId')
          .order('created_at', ascending: false);

      // Fetch which ones this user has already read
      final reads = await _client
          .from('notification_reads')
          .select('notification_id')
          .eq('user_id', userId);

      final readIds =
          (reads as List).map((r) => r['notification_id'] as String).toSet();

      return (notifs as List).map((json) {
        final isRead = readIds.contains(json['id'] as String);
        return NotificationModel.fromJson(
            json as Map<String, dynamic>, isRead: isRead);
      }).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> markAsRead(String notificationId, String userId) async {
    try {
      await _client.from('notification_reads').upsert({
        'notification_id': notificationId,
        'user_id': userId,
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    try {
      // Get all unread notification IDs for this user
      final notifs = await _client
          .from('notifications')
          .select('id')
          .or('target_type.eq.all,target_user_id.eq.$userId');

      final reads = await _client
          .from('notification_reads')
          .select('notification_id')
          .eq('user_id', userId);

      final readIds =
          (reads as List).map((r) => r['notification_id'] as String).toSet();

      final unreadIds = (notifs as List)
          .map((n) => n['id'] as String)
          .where((id) => !readIds.contains(id))
          .toList();

      if (unreadIds.isEmpty) return;

      await _client.from('notification_reads').upsert(
            unreadIds
                .map((id) => {'notification_id': id, 'user_id': userId})
                .toList(),
          );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Stream<List<NotificationEntity>> watchNotifications(String userId) {
    // Supabase .stream() applies RLS automatically.
    // We map each emission to entities with a best-effort read-status fetch.
    return _client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .asyncMap((rows) async {
          try {
            final reads = await _client
                .from('notification_reads')
                .select('notification_id')
                .eq('user_id', userId);

            final readIds = (reads as List)
                .map((r) => r['notification_id'] as String)
                .toSet();

            // Filter to only rows this user can see (Realtime may return all)
            return rows
                .where((r) =>
                    r['target_type'] == 'all' ||
                    r['target_user_id'] == userId)
                .map((json) {
              final isRead = readIds.contains(json['id'] as String);
              return NotificationModel.fromJson(json, isRead: isRead);
            }).toList();
          } catch (e) {
            debugPrint('[Notifications] watchNotifications error: $e');
            return <NotificationEntity>[];
          }
        });
  }
}
