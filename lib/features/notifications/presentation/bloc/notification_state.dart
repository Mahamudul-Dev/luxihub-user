part of 'notification_bloc.dart';

sealed class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

final class NotificationInitial extends NotificationState {}

final class NotificationLoading extends NotificationState {}

final class NotificationLoaded extends NotificationState {
  final List<NotificationEntity> notifications;
  const NotificationLoaded(this.notifications);

  int get unreadCount => notifications.where((n) => !n.isRead).length;
  bool get hasUnread => unreadCount > 0;

  @override
  List<Object> get props => [notifications];
}

final class NotificationError extends NotificationState {
  final String message;
  const NotificationError(this.message);

  @override
  List<Object> get props => [message];
}
