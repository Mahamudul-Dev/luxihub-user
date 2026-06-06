import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/domain/entities/conversation.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../home/data/models/service_provider_model.dart';
import '../bloc/chat_bloc.dart';

class ChatPage extends StatefulWidget {
  final Conversation conversation;
  const ChatPage({super.key, required this.conversation});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _hasText = false;
  bool _loadingProfile = false;

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(MessagesWatchStarted(widget.conversation.id));
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasText) setState(() => _hasText = hasText);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    context.read<ChatBloc>().add(MessageSendRequested(
          conversationId: widget.conversation.id,
          text: text,
        ));
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _goToProviderProfile() async {
    if (_loadingProfile) return;
    setState(() => _loadingProfile = true);
    try {
      final row = await Supabase.instance.client
          .from('profiles')
          .select('*, skills(name), reviews!reviews_provider_id_fkey(score)')
          .eq('id', widget.conversation.providerId)
          .single();
      final provider = ServiceProviderModel.fromJson(row);
      if (mounted) {
        context.pushNamed(
          'ServiceProviderProfile',
          pathParameters: {'id': provider.id},
          extra: provider,
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not load provider profile')),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingProfile = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = (context.read<AuthBloc>().state is AuthAuthenticated)
        ? (context.read<AuthBloc>().state as AuthAuthenticated).user.id
        : '';

    return Scaffold(
      backgroundColor: const Color(0xFFECEFF1),
      appBar: _AppBar(
        conversation: widget.conversation,
        loading: _loadingProfile,
        onTapProfile: _goToProviderProfile,
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<ChatBloc, ChatState>(
              listener: (context, state) {
                if (state is MessagesWatching) {
                  WidgetsBinding.instance
                      .addPostFrameCallback((_) => _scrollToBottom());
                } else if (state is ChatError) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error,
                  ));
                }
              },
              builder: (context, state) {
                if (state is! MessagesWatching) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.messages.isEmpty) {
                  return _EmptyState(
                    name: widget.conversation.providerName ?? 'Provider',
                  );
                }
                return ListView.builder(
                  controller: _scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  itemCount: state.messages.length,
                  itemBuilder: (context, index) {
                    final msg = state.messages[index];
                    final isMine = msg.senderId == uid;
                    final showDate = index == 0 ||
                        !_sameDay(
                            state.messages[index - 1].createdAt, msg.createdAt);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (showDate) _DateDivider(date: msg.createdAt),
                        _MessageBubble(
                          text: msg.text,
                          isMine: isMine,
                          time: _formatTime(msg.createdAt),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          _InputBar(
            controller: _controller,
            hasText: _hasText,
            onSend: _send,
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// ── AppBar ────────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  final Conversation conversation;
  final bool loading;
  final VoidCallback onTapProfile;

  const _AppBar({
    required this.conversation,
    required this.loading,
    required this.onTapProfile,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    final name = conversation.providerName ?? 'Provider';
    final avatar = conversation.providerAvatarPath;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          leadingWidth: 44,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
            color: AppColors.textPrimary,
            onPressed: () => context.pop(),
          ),
          title: GestureDetector(
            onTap: onTapProfile,
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Hero(
                  tag: 'provider-avatar-${conversation.providerId}',
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primaryLight.withValues(alpha: 0.2),
                    backgroundImage: avatar?.isNotEmpty == true
                        ? NetworkImage(avatar!)
                        : null,
                    child: avatar?.isNotEmpty != true
                        ? Text(
                            name[0].toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Text(
                        'Tap to view profile',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            if (loading)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              )
            else
              IconButton(
                icon: const Icon(Icons.account_circle_outlined),
                color: AppColors.textSecondary,
                tooltip: 'View profile',
                onPressed: onTapProfile,
              ),
          ],
        ),
        Container(height: 1, color: AppColors.divider),
      ],
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String name;
  const _EmptyState({required this.name});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 36,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Start a conversation',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Say hello to $name and describe what you need.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Date divider ──────────────────────────────────────────────────────────────

class _DateDivider extends StatelessWidget {
  final DateTime date;
  const _DateDivider({required this.date});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final String label;
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      label = 'Today';
    } else if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1) {
      label = 'Yesterday';
    } else {
      label =
          '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          const Expanded(child: Divider(endIndent: 12)),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Expanded(child: Divider(indent: 12)),
        ],
      ),
    );
  }
}

// ── Message bubble ────────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final String text;
  final bool isMine;
  final String time;

  const _MessageBubble({
    required this.text,
    required this.isMine,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 2,
        bottom: 2,
        left: isMine ? 60 : 0,
        right: isMine ? 0 : 60,
      ),
      child: Align(
        alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isMine ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(isMine ? 18 : 4),
              bottomRight: Radius.circular(isMine ? 4 : 18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment:
                isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: TextStyle(
                  color: isMine ? Colors.white : AppColors.textPrimary,
                  fontSize: 14.5,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: TextStyle(
                  color: isMine
                      ? Colors.white.withValues(alpha: 0.65)
                      : AppColors.textHint,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Input bar ─────────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool hasText;
  final VoidCallback onSend;

  const _InputBar({
    required this.controller,
    required this.hasText,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F2F5),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: controller,
                    textInputAction: TextInputAction.newline,
                    keyboardType: TextInputType.multiline,
                    maxLines: 5,
                    minLines: 1,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Message...',
                      hintStyle: TextStyle(
                        color: AppColors.textHint,
                        fontSize: 15,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: hasText ? AppColors.primary : const Color(0xFFDDE1E4),
                  shape: BoxShape.circle,
                ),
                child: Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: hasText ? onSend : null,
                    child: Icon(
                      Icons.send_rounded,
                      size: 20,
                      color: hasText ? Colors.white : AppColors.textHint,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
