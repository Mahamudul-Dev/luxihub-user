import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/domain/entities/conversation.dart';
import '../../../../core/domain/entities/message.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../home/data/models/service_provider_model.dart';
import '../../domain/repositories/chat_repository.dart';
import '../bloc/chat_bloc.dart';

// ── Formatting helpers ────────────────────────────────────────────────────────

String _formatTime(DateTime dt) {
  final local = dt.toLocal();
  final hour = local.hour == 0 ? 12 : (local.hour > 12 ? local.hour - 12 : local.hour);
  final minute = local.minute.toString().padLeft(2, '0');
  final period = local.hour < 12 ? 'AM' : 'PM';
  return '$hour:$minute $period';
}

String _formatDateLabel(DateTime dt) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final day = DateTime(dt.year, dt.month, dt.day);

  if (day == today) return 'Today';
  if (day == yesterday) return 'Yesterday';

  const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  final wd = weekdays[dt.weekday - 1];
  final mo = months[dt.month - 1];
  if (dt.year == now.year) return '$wd, ${dt.day} $mo';
  return '$wd, ${dt.day} $mo ${dt.year}';
}

// ── List item union ───────────────────────────────────────────────────────────

class _Item {
  final Message? message;
  final String? separator;
  const _Item.msg(this.message) : separator = null;
  const _Item.sep(this.separator) : message = null;
  bool get isSep => separator != null;
}

// Build items chronologically with date separators, then reverse for
// reverse:true ListView so newest message is at the bottom (index 0).
List<_Item> _buildItems(List<Message> messages) {
  // Always sort oldest→newest regardless of stream delivery order
  final sorted = [...messages]
    ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  final items = <_Item>[];
  DateTime? lastDate;

  for (final msg in sorted) {
    final dt = msg.createdAt.toLocal();
    final date = DateTime(dt.year, dt.month, dt.day);
    if (lastDate == null || date != lastDate) {
      items.add(_Item.sep(_formatDateLabel(dt)));
      lastDate = date;
    }
    items.add(_Item.msg(msg));
  }

  // Reverse so index 0 = newest → renders at bottom with reverse:true
  return items.reversed.toList();
}

// ── Page ──────────────────────────────────────────────────────────────────────

class ChatPage extends StatefulWidget {
  final Conversation conversation;
  const ChatPage({super.key, required this.conversation});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _loadingProfile = false;

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(MessagesWatchStarted(widget.conversation.id));
    // markAsRead runs outside the bloc because emit.forEach in MessagesWatchStarted
    // holds the event queue open, so any queued event behind it never executes.
    sl<ChatRepository>().markAsRead(widget.conversation.id).then((_) {
      debugPrint('[MarkAsRead] SUCCESS for conv: ${widget.conversation.id}');
    }).catchError((e) {
      debugPrint('[MarkAsRead] FAILED: $e');
    });
  }

  @override
  void dispose() {
    sl<ChatRepository>().markAsRead(widget.conversation.id);
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // With reverse:true, position 0 = bottom of the chat.
  void _scrollToBottom({bool jump = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      if (jump) {
        _scrollController.jumpTo(0);
      } else {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    setState(() {});
    context.read<ChatBloc>().add(MessageSendRequested(
          conversationId: widget.conversation.id,
          text: text,
        ));
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
    final name = widget.conversation.providerName ?? 'Provider';
    final avatar = widget.conversation.providerAvatarPath;

    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          color: AppColors.textPrimary,
          onPressed: () => context.pop(),
        ),
        title: GestureDetector(
          onTap: _goToProviderProfile,
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              CircleAvatar(
                radius: 18.r,
                backgroundColor: AppColors.splashShapeColor,
                backgroundImage: avatar?.isNotEmpty == true
                    ? NetworkImage(avatar!)
                    : null,
                child: avatar?.isNotEmpty != true
                    ? Text(
                        name[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      )
                    : null,
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Tap to view profile',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
       
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.h),
          child: Divider(height: 1.h, color: AppColors.divider),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<ChatBloc, ChatState>(
              listener: (context, state) {
                if (state is MessagesWatching) {
                  _scrollToBottom(jump: state.messages.length <= 1);
                }
                if (state is ChatError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is! MessagesWatching) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = state.messages;

                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      'No messages yet. Say hello!',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textHint,
                      ),
                    ),
                  );
                }

                final uid =
                    (context.read<AuthBloc>().state is AuthAuthenticated)
                        ? (context.read<AuthBloc>().state as AuthAuthenticated)
                            .user
                            .id
                        : '';

                final items = _buildItems(messages);

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    if (item.isSep) {
                      return _DateSeparator(label: item.separator!);
                    }
                    final msg = item.message!;
                    return _ChatBubble(
                      text: msg.text,
                      time: _formatTime(msg.createdAt),
                      isSent: msg.senderId == uid,
                      providerAvatar: avatar,
                      providerInitial: name[0].toUpperCase(),
                    );
                  },
                );
              },
            ),
          ),

          // ── Input bar ─────────────────────────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(16.w, 10.h, 12.w, 24.h),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border(
                top: BorderSide(color: AppColors.divider, width: 1.h),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 120.h),
                    child: TextField(
                      controller: _controller,
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (_) => setState(() {}),
                      style: TextStyle(
                          fontSize: 14.sp, color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(
                            fontSize: 14.sp, color: AppColors.textHint),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 10.h),
                        filled: true,
                        fillColor: AppColors.surfaceBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22.r),
                          borderSide:
                              const BorderSide(color: AppColors.inputBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22.r),
                          borderSide:
                              const BorderSide(color: AppColors.inputBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22.r),
                          borderSide: const BorderSide(
                              color: AppColors.primary, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 44.r,
                  height: 44.r,
                  decoration: BoxDecoration(
                    color: _controller.text.trim().isNotEmpty
                        ? AppColors.primary
                        : AppColors.divider,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _controller.text.trim().isNotEmpty ? _send : null,
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.send_rounded,
                      size: 20.r,
                      color: _controller.text.trim().isNotEmpty
                          ? AppColors.textOnPrimary
                          : AppColors.textHint,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Chat bubble ───────────────────────────────────────────────────────────────

class _ChatBubble extends StatelessWidget {
  final String text;
  final String time;
  final bool isSent;
  final String? providerAvatar;
  final String providerInitial;

  const _ChatBubble({
    required this.text,
    required this.time,
    required this.isSent,
    required this.providerAvatar,
    required this.providerInitial,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisAlignment:
            isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isSent) ...[
            CircleAvatar(
              radius: 14.r,
              backgroundColor: AppColors.splashShapeColor,
              backgroundImage: providerAvatar?.isNotEmpty == true
                  ? NetworkImage(providerAvatar!)
                  : null,
              child: providerAvatar?.isNotEmpty != true
                  ? Text(
                      providerInitial,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 8.w),
          ],
          Flexible(
            child: Container(
              margin: EdgeInsets.only(bottom: 12.h),
              padding:
                  EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width * 0.68,
              ),
              decoration: BoxDecoration(
                color: isSent ? AppColors.primary : AppColors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                  bottomLeft:
                      isSent ? Radius.circular(16.r) : Radius.circular(4.r),
                  bottomRight:
                      isSent ? Radius.circular(4.r) : Radius.circular(16.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment:
                    isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                      color: isSent
                          ? AppColors.textOnPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: isSent
                          ? AppColors.textOnPrimary.withValues(alpha: 0.65)
                          : AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isSent) ...[
            SizedBox(width: 8.w),
            CircleAvatar(
              radius: 14.r,
              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
              child: Icon(
                Icons.person_rounded,
                size: 16.r,
                color: AppColors.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Date separator ────────────────────────────────────────────────────────────

class _DateSeparator extends StatelessWidget {
  const _DateSeparator({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Row(
        children: [
          Expanded(
              child: Divider(color: AppColors.divider, thickness: 1.h)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: AppColors.divider),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppColors.textHint,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Expanded(
              child: Divider(color: AppColors.divider, thickness: 1.h)),
        ],
      ),
    );
  }
}
