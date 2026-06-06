part of 'chat_bloc.dart';

sealed class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object> get props => [];
}

final class ConversationsRequested extends ChatEvent {
  final String clientId;
  const ConversationsRequested(this.clientId);

  @override
  List<Object> get props => [clientId];
}

final class MessagesWatchStarted extends ChatEvent {
  final String conversationId;
  const MessagesWatchStarted(this.conversationId);

  @override
  List<Object> get props => [conversationId];
}

final class MessageSendRequested extends ChatEvent {
  final String conversationId;
  final String text;
  const MessageSendRequested({required this.conversationId, required this.text});

  @override
  List<Object> get props => [conversationId, text];
}
