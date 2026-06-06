import '../../../../core/domain/entities/conversation.dart';
import '../repositories/chat_repository.dart';

class GetOrCreateConversation {
  final ChatRepository _repository;
  const GetOrCreateConversation(this._repository);

  Future<Conversation> call({
    required String clientId,
    required String providerId,
    required String jobRequestId,
  }) =>
      _repository.getOrCreateConversation(
        clientId: clientId,
        providerId: providerId,
        jobRequestId: jobRequestId,
      );
}
