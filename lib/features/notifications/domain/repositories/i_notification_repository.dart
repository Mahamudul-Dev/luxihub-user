import '../entities/notification_entity.dart';

abstract interface class INotificationRepository {
  Future<List<NotificationEntity>> getNotifications(String userId);
  Future<void> markAsRead(String notificationId, String userId);
  Future<void> markAllAsRead(String userId);
  Stream<List<NotificationEntity>> watchNotifications(String userId);
}
