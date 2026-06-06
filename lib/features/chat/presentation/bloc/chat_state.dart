part of 'chat_bloc.dart';

sealed class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

final class ChatInitial extends ChatState {}

final class ConversationsLoading extends ChatState {}

final class ConversationsLoaded extends ChatState {
  final List<Conversation> conversations;
  const ConversationsLoaded(this.conversations);

  @override
  List<Object> get props => [conversations];
}

final class MessagesWatching extends ChatState {
  final List<Message> messages;
  const MessagesWatching(this.messages);

  @override
  List<Object> get props => [messages];
}

final class ChatError extends ChatState {
  final String message;
  const ChatError(this.message);

  @override
  List<Object> get props => [message];
}
