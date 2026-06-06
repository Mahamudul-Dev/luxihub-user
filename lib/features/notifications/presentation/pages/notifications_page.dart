import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/utils.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/notification_entity.dart';
import '../bloc/notification_bloc.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        final hasUnread =
            state is NotificationLoaded && state.hasUnread;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Notifications'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            actions: [
              if (hasUnread)
                TextButton(
                  onPressed: () {
                    final auth = context.read<AuthBloc>().state;
                    if (auth is AuthAuthenticated) {
                      context.read<NotificationBloc>().add(
                            NotificationMarkAllReadRequested(auth.user.id),
                          );
                    }
                  },
                  child: const Text(
                    'Mark all read',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
            ],
          ),
          body: switch (state) {
            NotificationInitial() || NotificationLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            NotificationError(:final message) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(Utils.defaultPadding * 2),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline,
                          size: 48, color: Colors.red.shade300),
                      const SizedBox(height: 12),
                      Text(message,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ),
            NotificationLoaded(:final notifications)
                when notifications.isEmpty =>
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.notifications_none_outlined,
                        size: 72, color: AppColors.textHint),
                    const SizedBox(height: 16),
                    Text('No notifications yet',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    Text(
                      "You'll be notified when something\nimportant happens.",
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.textHint),
                    ),
                  ],
                ),
              ),
            NotificationLoaded(:final notifications) => ListView.separated(
                padding: const EdgeInsets.symmetric(
                    vertical: Utils.defaultPadding / 2),
                itemCount: notifications.length,
                separatorBuilder: (_, _) =>
                    const Divider(height: 1, indent: 72),
                itemBuilder: (context, i) {
                  final notif = notifications[i];
                  final auth = context.read<AuthBloc>().state;
                  final userId =
                      auth is AuthAuthenticated ? auth.user.id : '';

                  return _NotificationTile(
                    notification: notif,
                    onTap: notif.isRead
                        ? null
                        : () => context.read<NotificationBloc>().add(
                              NotificationMarkReadRequested(
                                notificationId: notif.id,
                                userId: userId,
                              ),
                            ),
                  );
                },
              ),
          },
        );
      },
    );
  }
}

// ── Notification tile ──────────────────────────────────────────────────────────

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, this.onTap});

  final NotificationEntity notification;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isRead = notification.isRead;

    return InkWell(
      onTap: onTap,
      child: Container(
        color: isRead ? Colors.transparent : AppColors.primary.withValues(alpha: 0.04),
        padding: const EdgeInsets.symmetric(
          horizontal: Utils.defaultPadding,
          vertical: Utils.defaultPadding * 0.9,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon circle
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _iconBg(notification.type),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _icon(notification.type),
                color: Colors.white,
                size: 22,
              ),
            ),

            const SizedBox(width: 12),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                fontWeight: isRead
                                    ? FontWeight.w500
                                    : FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                        ),
                      ),
                      // Unread blue dot
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 6, top: 2),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notification.body,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(notification.createdAt),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textHint,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _icon(String type) => switch (type) {
        'job_update' => Icons.work_outline_rounded,
        'payment' => Icons.payments_outlined,
        'system' => Icons.settings_outlined,
        _ => Icons.notifications_outlined,
      };

  Color _iconBg(String type) => switch (type) {
        'job_update' => AppColors.primary,
        'payment' => Colors.green.shade600,
        'system' => Colors.blueGrey,
        _ => AppColors.primaryLight,
      };

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[dt.month - 1]} ${dt.day}';
  }
}
