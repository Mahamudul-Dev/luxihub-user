import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/domain/entities/conversation.dart';
import '../../../../core/domain/entities/message.dart';
import '../../../../core/error/exceptions.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

abstract interface class ChatRemoteDataSource {
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

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final SupabaseClient _client;
  const ChatRemoteDataSourceImpl(this._client);

  @override
  Future<List<Conversation>> getConversations(String clientId) async {
    try {
      final response = await _client
          .from('conversations')
          .select('*, provider:provider_id(name, avatar_path)')
          .eq('client_id', clientId)
          .order('last_message_at', ascending: false);

      return (response as List)
          .map((j) => ConversationModel.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Conversation> getOrCreateConversation({
    required String clientId,
    required String providerId,
    required String jobRequestId,
  }) async {
    try {
      const select = '*, provider:provider_id(name, avatar_path)';

      final existing = await _client
          .from('conversations')
          .select(select)
          .eq('job_request_id', jobRequestId)
          .eq('client_id', clientId)
          .maybeSingle();

      if (existing != null) {
        return ConversationModel.fromJson(existing);
      }

      final created = await _client
          .from('conversations')
          .insert({
            'job_request_id': jobRequestId,
            'client_id': clientId,
            'provider_id': providerId,
          })
          .select(select)
          .single();

      return ConversationModel.fromJson(created);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Stream<List<Message>> watchMessages(String conversationId) {
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .order('created_at')
        .map((rows) => rows.map(MessageModel.fromJson).toList());
  }

  @override
  Future<Message> sendMessage({
    required String conversationId,
    required String senderId,
    required String text,
  }) async {
    try {
      final row = await _client
          .from('messages')
          .insert({
            'conversation_id': conversationId,
            'sender_id': senderId,
            'text': text,
          })
          .select()
          .single();

      return MessageModel.fromJson(row);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
