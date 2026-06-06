import '../../domain/entities/notification_entity.dart';

class NotificationModel {
  static NotificationEntity fromJson(
    Map<String, dynamic> json, {
    required bool isRead,
  }) {
    return NotificationEntity(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      type: json['type'] as String? ?? 'general',
      targetType: json['target_type'] as String? ?? 'all',
      targetUserId: json['target_user_id'] as String?,
      data: json['data'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      isRead: isRead,
    );
  }
}
