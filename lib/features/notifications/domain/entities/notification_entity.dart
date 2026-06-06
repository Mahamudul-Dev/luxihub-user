class NotificationEntity {
  final String id;
  final String title;
  final String body;
  final String type; // 'general' | 'job_update' | 'payment' | 'system'
  final String targetType; // 'all' | 'user'
  final String? targetUserId;
  final Map<String, dynamic>? data;
  final DateTime createdAt;
  final bool isRead;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.targetType,
    this.targetUserId,
    this.data,
    required this.createdAt,
    required this.isRead,
  });

  NotificationEntity copyWith({bool? isRead}) => NotificationEntity(
        id: id,
        title: title,
        body: body,
        type: type,
        targetType: targetType,
        targetUserId: targetUserId,
        data: data,
        createdAt: createdAt,
        isRead: isRead ?? this.isRead,
      );
}
