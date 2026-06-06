import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/domain/entities/conversation.dart';
import '../../../../core/domain/entities/message.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../domain/usecases/get_conversations.dart';
import '../../domain/usecases/send_message.dart';
import '../../domain/usecases/watch_messages.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final AuthBloc _authBloc;
  final GetConversations _getConversations;
  final WatchMessages _watchMessages;
  final SendMessage _sendMessage;

  ChatBloc({
    required AuthBloc authBloc,
    required GetConversations getConversations,
    required WatchMessages watchMessages,
    required SendMessage sendMessage,
  })  : _authBloc = authBloc,
        _getConversations = getConversations,
        _watchMessages = watchMessages,
        _sendMessage = sendMessage,
        super(ChatInitial()) {
    on<ConversationsRequested>(_onConversationsRequested);
    on<MessagesWatchStarted>(_onMessagesWatchStarted);
    on<MessageSendRequested>(_onMessageSendRequested);
  }

  String? get _uid {
    final s = _authBloc.state;
    return s is AuthAuthenticated ? s.user.id : null;
  }

  Future<void> _onConversationsRequested(
    ConversationsRequested event,
    Emitter<ChatState> emit,
  ) async {
    emit(ConversationsLoading());
    try {
      final conversations = await _getConversations(event.clientId);
      emit(ConversationsLoaded(conversations));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onMessagesWatchStarted(
    MessagesWatchStarted event,
    Emitter<ChatState> emit,
  ) async {
    emit(MessagesWatching([]));
    await emit.forEach<List<Message>>(
      _watchMessages(event.conversationId),
      onData: MessagesWatching.new,
      onError: (e, _) => ChatError(e.toString()),
    );
  }

  Future<void> _onMessageSendRequested(
    MessageSendRequested event,
    Emitter<ChatState> emit,
  ) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      await _sendMessage(SendMessageParams(
        conversationId: event.conversationId,
        senderId: uid,
        text: event.text,
      ));
      // Realtime stream will automatically update MessagesWatching state.
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }
}
