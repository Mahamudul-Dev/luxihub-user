import 'package:equatable/equatable.dart';

import '../../../../core/domain/entities/message.dart';
import '../repositories/chat_repository.dart';

class SendMessage {
  final ChatRepository _repository;
  const SendMessage(this._repository);

  Future<Message> call(SendMessageParams params) => _repository.sendMessage(
        conversationId: params.conversationId,
        senderId: params.senderId,
        text: params.text,
      );
}

class SendMessageParams extends Equatable {
  final String conversationId;
  final String senderId;
  final String text;

  const SendMessageParams({
    required this.conversationId,
    required this.senderId,
    required this.text,
  });

  @override
  List<Object> get props => [conversationId, senderId, text];
}
