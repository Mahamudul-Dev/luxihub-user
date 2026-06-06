import '../repositories/i_notification_repository.dart';

class MarkNotificationRead {
  final INotificationRepository _repository;
  const MarkNotificationRead(this._repository);

  Future<void> call(String notificationId, String userId) =>
      _repository.markAsRead(notificationId, userId);
}
