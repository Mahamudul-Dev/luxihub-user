import '../repositories/i_notification_repository.dart';

class MarkAllNotificationsRead {
  final INotificationRepository _repository;
  const MarkAllNotificationsRead(this._repository);

  Future<void> call(String userId) => _repository.markAllAsRead(userId);
}
