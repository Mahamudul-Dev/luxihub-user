import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/config/utils.dart';

class UserProfileBar extends StatelessWidget {
  const UserProfileBar({
    super.key,

    // Identity
    required this.name,
    required this.subtitle,

    // Avatar
    this.avatarImageProvider,
    this.avatarRadius = Utils.defaultBorderRadius * 3,
    this.avatarBackgroundColor,
    this.avatarFallbackIcon,
    this.onAvatarTap,

    // Notification
    this.onNotificationTap,
    this.notificationCount = 0,
    this.showNotificationBadge = true,
    this.notificationIcon,

    // Text styles
    this.nameStyle,
    this.subtitleStyle,

    // Layout
    this.padding,
    this.spacing = 8.0,
  });

  /// Display name shown in bold.
  final String name;

  /// Secondary line — typically email or role.
  final String subtitle;

  /// Image to show inside the avatar (asset, network, etc.).
  final ImageProvider? avatarImageProvider;

  /// Radius of the [CircleAvatar]. Defaults to `defaultBorderRadius * 3`.
  final double avatarRadius;

  /// Background color of the avatar (shown behind initials / icon fallback).
  final Color? avatarBackgroundColor;

  /// Icon shown when [avatarImageProvider] is null. Defaults to a person icon.
  final Widget? avatarFallbackIcon;

  /// Called when the avatar is tapped (e.g. open profile page).
  final VoidCallback? onAvatarTap;

  /// Called when the notification bell is tapped.
  final VoidCallback? onNotificationTap;

  /// Number shown on the badge. 0 = no badge rendered.
  final int notificationCount;

  /// Whether to render the badge dot/count at all.
  final bool showNotificationBadge;

  /// Override the default notification bell icon.
  final Widget? notificationIcon;

  /// Style for the [name] text.
  final TextStyle? nameStyle;

  /// Style for the [subtitle] text.
  final TextStyle? subtitleStyle;

  /// Outer padding of the bar. Defaults to zero.
  final EdgeInsetsGeometry? padding;

  /// Horizontal gap between avatar and text column.
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Avatar + text
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: onAvatarTap,
                child: CircleAvatar(
                  radius: avatarRadius,
                  backgroundColor:
                      avatarBackgroundColor ?? AppColors.primary,
                  backgroundImage: avatarImageProvider,
                  child: avatarImageProvider == null
                      ? (avatarFallbackIcon ??
                          const Icon(Icons.person, color: Colors.white))
                      : null,
                ),
              ),
              SizedBox(width: spacing),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: nameStyle ??
                        Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                  ),
                  Text(
                    subtitle,
                    style: subtitleStyle ??
                        Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                  ),
                ],
              ),
            ],
          ),

          // Notification button
          _NotificationButton(
            onTap: onNotificationTap,
            count: notificationCount,
            showBadge: showNotificationBadge,
            icon: notificationIcon,
          ),
        ],
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({
    required this.onTap,
    required this.count,
    required this.showBadge,
    this.icon,
  });

  final VoidCallback? onTap;
  final int count;
  final bool showBadge;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final hasBadge = showBadge && count > 0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: onTap,
          icon: icon ??
              Icon(
                Icons.notifications_none_outlined,
                color: Theme.of(context).primaryColor,
              ),
        ),
        if (hasBadge)
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                count > 99 ? '99+' : '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
