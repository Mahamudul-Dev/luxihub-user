import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/utils.dart';
import '../../../../core/domain/entities/conversation.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../bloc/chat_bloc.dart';

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<ChatBloc>().add(ConversationsRequested(authState.user.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inbox')),
      body: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is ChatError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ));
          }
        },
        builder: (context, state) {
          if (state is ConversationsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ConversationsLoaded) {
            if (state.conversations.isEmpty) {
              return const Center(child: Text('No conversations yet.'));
            }
            return RefreshIndicator(
              onRefresh: () async {
                final authState = context.read<AuthBloc>().state;
                if (authState is AuthAuthenticated) {
                  context
                      .read<ChatBloc>()
                      .add(ConversationsRequested(authState.user.id));
                }
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(Utils.defaultPadding),
                itemCount: state.conversations.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final conv = state.conversations[index];
                  return _ConversationTile(conversation: conv);
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final Conversation conversation;
  const _ConversationTile({required this.conversation});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => context.pushNamed(
        AppRoutes.chat.name,
        pathParameters: {'conversationId': conversation.id},
        extra: conversation,
      ),
      leading: CircleAvatar(
        backgroundColor: AppColors.divider,
        backgroundImage: conversation.providerAvatarPath != null
            ? NetworkImage(conversation.providerAvatarPath!)
            : null,
        child: conversation.providerAvatarPath == null
            ? const Icon(Icons.person, color: AppColors.textSecondary)
            : null,
      ),
      title: Text(
        conversation.providerName ?? 'Provider',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: conversation.lastMessage != null
          ? Text(
              conversation.lastMessage!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textSecondary),
            )
          : null,
      trailing: conversation.unreadCount > 0
          ? CircleAvatar(
              radius: 10,
              backgroundColor: AppColors.primary,
              child: Text(
                '${conversation.unreadCount}',
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            )
          : null,
    );
  }
}
