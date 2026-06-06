import '../../../../core/domain/entities/conversation.dart';
import '../../../../core/domain/entities/message.dart';

abstract interface class ChatRepository {
  Future<List<Conversation>> getConversations(String clientId);
  Future<Conversation> getOrCreateConversation({
    required String clientId,
    required String providerId,
    required String jobRequestId,
  });
  Stream<List<Message>> watchMessages(String conversationId);
  Future<Message> sendMessage({
    required String conversationId,
    required String senderId,
    required String text,
  });
}
