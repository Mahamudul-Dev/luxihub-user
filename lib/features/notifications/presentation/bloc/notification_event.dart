part of 'notification_bloc.dart';

sealed class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

final class NotificationsWatchStarted extends NotificationEvent {
  final String userId;
  const NotificationsWatchStarted(this.userId);

  @override
  List<Object> get props => [userId];
}

final class NotificationMarkReadRequested extends NotificationEvent {
  final String notificationId;
  final String userId;
  const NotificationMarkReadRequested({
    required this.notificationId,
    required this.userId,
  });

  @override
  List<Object> get props => [notificationId, userId];
}

final class NotificationMarkAllReadRequested extends NotificationEvent {
  final String userId;
  const NotificationMarkAllReadRequested(this.userId);

  @override
  List<Object> get props => [userId];
}
