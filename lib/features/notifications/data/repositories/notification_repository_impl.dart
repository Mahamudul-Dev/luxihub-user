import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/i_notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';

class NotificationRepositoryImpl implements INotificationRepository {
  final NotificationRemoteDataSource _dataSource;
  const NotificationRepositoryImpl(this._dataSource);

  @override
  Future<List<NotificationEntity>> getNotifications(String userId) =>
      _dataSource.getNotifications(userId);

  @override
  Future<void> markAsRead(String notificationId, String userId) =>
      _dataSource.markAsRead(notificationId, userId);

  @override
  Future<void> markAllAsRead(String userId) =>
      _dataSource.markAllAsRead(userId);

  @override
  Stream<List<NotificationEntity>> watchNotifications(String userId) =>
      _dataSource.watchNotifications(userId);
}
