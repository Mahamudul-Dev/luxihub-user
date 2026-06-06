import '../../../../core/domain/entities/conversation.dart';

class ConversationModel {
  static Conversation fromJson(Map<String, dynamic> json) {
    final providerJson = json['provider'] as Map<String, dynamic>?;

    return Conversation(
      id: json['id'] as String,
      jobRequestId: json['job_request_id'] as String,
      providerId: json['provider_id'] as String,
      clientId: json['client_id'] as String,
      lastMessage: json['last_message'] as String?,
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'] as String)
          : null,
      unreadCount: (json['unread_count'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      providerName: providerJson?['name'] as String?,
      providerAvatarPath: providerJson?['avatar_path'] as String?,
    );
  }
}
