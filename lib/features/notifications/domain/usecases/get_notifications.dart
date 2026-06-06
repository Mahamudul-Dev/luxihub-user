import '../entities/notification_entity.dart';
import '../repositories/i_notification_repository.dart';

class GetNotifications {
  final INotificationRepository _repository;
  const GetNotifications(this._repository);

  Future<List<NotificationEntity>> call(String userId) =>
      _repository.getNotifications(userId);

  Stream<List<NotificationEntity>> watch(String userId) =>
      _repository.watchNotifications(userId);
}
