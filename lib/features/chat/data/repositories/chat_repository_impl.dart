import '../../../../core/domain/entities/conversation.dart';
import '../../../../core/domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource _dataSource;
  const ChatRepositoryImpl(this._dataSource);

  @override
  Future<List<Conversation>> getConversations(String clientId) =>
      _dataSource.getConversations(clientId);

  @override
  Future<Conversation> getOrCreateConversation({
    required String clientId,
    required String providerId,
    required String jobRequestId,
  }) =>
      _dataSource.getOrCreateConversation(
        clientId: clientId,
        providerId: providerId,
        jobRequestId: jobRequestId,
      );

  @override
  Stream<List<Message>> watchMessages(String conversationId) =>
      _dataSource.watchMessages(conversationId);

  @override
  Future<Message> sendMessage({
    required String conversationId,
    required String senderId,
    required String text,
  }) =>
      _dataSource.sendMessage(
        conversationId: conversationId,
        senderId: senderId,
        text: text,
      );
}
