import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/notification_entity.dart';
import '../../domain/usecases/get_notifications.dart';
import '../../domain/usecases/mark_all_notifications_read.dart';
import '../../domain/usecases/mark_notification_read.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotifications _getNotifications;
  final MarkNotificationRead _markRead;
  final MarkAllNotificationsRead _markAllRead;

  NotificationBloc({
    required GetNotifications getNotifications,
    required MarkNotificationRead markRead,
    required MarkAllNotificationsRead markAllRead,
  })  : _getNotifications = getNotifications,
        _markRead = markRead,
        _markAllRead = markAllRead,
        super(NotificationInitial()) {
    on<NotificationsWatchStarted>(_onWatchStarted);
    on<NotificationMarkReadRequested>(_onMarkRead);
    on<NotificationMarkAllReadRequested>(_onMarkAllRead);
  }

  Future<void> _onWatchStarted(
    NotificationsWatchStarted event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    await emit.forEach<List<NotificationEntity>>(
      _getNotifications.watch(event.userId),
      onData: (notifications) => NotificationLoaded(notifications),
      onError: (e, _) => NotificationError(e.toString()),
    );
  }

  Future<void> _onMarkRead(
    NotificationMarkReadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    // Optimistically update the current list
    final current = state;
    if (current is NotificationLoaded) {
      final updated = current.notifications.map((n) {
        return n.id == event.notificationId ? n.copyWith(isRead: true) : n;
      }).toList();
      emit(NotificationLoaded(updated));
    }

    try {
      await _markRead(event.notificationId, event.userId);
    } catch (_) {
      // Revert on failure by re-emitting previous state
      if (current is NotificationLoaded) emit(current);
    }
  }

  Future<void> _onMarkAllRead(
    NotificationMarkAllReadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    final current = state;
    if (current is NotificationLoaded) {
      final updated =
          current.notifications.map((n) => n.copyWith(isRead: true)).toList();
      emit(NotificationLoaded(updated));
    }

    try {
      await _markAllRead(event.userId);
    } catch (_) {
      if (current is NotificationLoaded) emit(current);
    }
  }
}
