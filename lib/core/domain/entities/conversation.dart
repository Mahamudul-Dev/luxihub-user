import 'package:equatable/equatable.dart';

class Conversation extends Equatable {
  final String id;
  final String jobRequestId;
  final String providerId;
  final String clientId;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final DateTime createdAt;

  // Embedded for display (from profiles JOIN)
  final String? providerName;
  final String? providerAvatarPath;

  const Conversation({
    required this.id,
    required this.jobRequestId,
    required this.providerId,
    required this.clientId,
    this.lastMessage,
    this.lastMessageAt,
    required this.unreadCount,
    required this.createdAt,
    this.providerName,
    this.providerAvatarPath,
  });

  @override
  List<Object?> get props => [
        id, jobRequestId, providerId, clientId,
        lastMessage, lastMessageAt, unreadCount, createdAt,
        providerName, providerAvatarPath,
      ];
}
