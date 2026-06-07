import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/domain/entities/conversation.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../bloc/chat_bloc.dart';

String _relativeTime(DateTime? dt) {
  if (dt == null) return '';
  final diff = DateTime.now().difference(dt.toLocal());
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  static const _filters = ['All', 'Unread', 'Read'];

  String _selectedFilter = 'All';
  String _searchQuery = '';

  void _fetchConversations() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<ChatBloc>().add(ConversationsRequested(authState.user.id));
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchConversations();
  }

  List<Conversation> _filter(List<Conversation> convs) {
    return convs.where((c) {
      final matchesFilter = switch (_selectedFilter) {
        'Unread' => c.unreadCount > 0,
        'Read' => c.unreadCount == 0,
        _ => true,
      };
      final q = _searchQuery.toLowerCase();
      final matchesSearch = q.isEmpty ||
          (c.providerName ?? '').toLowerCase().contains(q) ||
          (c.lastMessage ?? '').toLowerCase().contains(q);
      return matchesFilter && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceBackground,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: BlocBuilder<ChatBloc, ChatState>(
          builder: (context, state) {
            final totalUnread = state is ConversationsLoaded
                ? state.conversations.fold(0, (s, c) => s + c.unreadCount)
                : 0;
            return Row(
              children: [
                Text(
                  'Messages',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (totalUnread > 0) ...[
                  SizedBox(width: 8.w),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(50.r),
                    ),
                    child: Text(
                      '$totalUnread',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.textOnPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.h),
          child: Divider(height: 1.h, color: AppColors.divider),
        ),
      ),
      body: Column(
        children: [
          // ── Search + filter ─────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style:
                      TextStyle(fontSize: 14.sp, color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Search conversations...',
                    hintStyle: TextStyle(
                        fontSize: 14.sp, color: AppColors.textHint),
                    prefixIcon: Icon(Icons.search_rounded,
                        size: 20.r, color: AppColors.textHint),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.close_rounded,
                                size: 18.r, color: AppColors.textHint),
                            onPressed: () =>
                                setState(() => _searchQuery = ''),
                          )
                        : null,
                    contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      borderSide:
                          const BorderSide(color: AppColors.inputBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      borderSide:
                          const BorderSide(color: AppColors.inputBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      borderSide:
                          const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: _filters.map((filter) {
                    final isActive = filter == _selectedFilter;
                    return Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _selectedFilter = filter),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.primary
                                : AppColors.background,
                            borderRadius: BorderRadius.circular(50.r),
                            border: Border.all(
                              color: isActive
                                  ? AppColors.primary
                                  : AppColors.inputBorder,
                            ),
                          ),
                          child: Text(
                            filter,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: isActive
                                  ? AppColors.textOnPrimary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 8.h),
              ],
            ),
          ),

          // ── List ────────────────────────────────────────────────────────
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _fetchConversations(),
              color: AppColors.primary,
              child: BlocConsumer<ChatBloc, ChatState>(
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
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: 300,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                    ],
                  );
                }

                final allConvs = state is ConversationsLoaded
                    ? state.conversations
                    : <Conversation>[];
                final items = _filter(allConvs);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (allConvs.isNotEmpty)
                      Padding(
                        padding:
                            EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h),
                        child: Text(
                          '${items.length} ${items.length == 1 ? 'conversation' : 'conversations'}',
                          style: TextStyle(
                              fontSize: 12.sp, color: AppColors.textHint),
                        ),
                      ),
                    Expanded(
                      child: items.isEmpty
                            ? ListView(
                                physics:
                                    const AlwaysScrollableScrollPhysics(),
                                children: [
                                  SizedBox(
                                    height: 320.h,
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.chat_bubble_outline_rounded,
                                            size: 56.r,
                                            color: AppColors.textHint,
                                          ),
                                          SizedBox(height: 16.h),
                                          Text(
                                            _searchQuery.isNotEmpty ||
                                                    _selectedFilter != 'All'
                                                ? 'No conversations found'
                                                : 'No conversations yet',
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          SizedBox(height: 8.h),
                                          Text(
                                            _searchQuery.isNotEmpty ||
                                                    _selectedFilter != 'All'
                                                ? 'Try adjusting your search or filter'
                                                : 'Request a service to start chatting\nwith a provider',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                              color: AppColors.textHint,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                physics:
                                    const AlwaysScrollableScrollPhysics(),
                                padding: EdgeInsets.fromLTRB(
                                    16.w, 4.h, 16.w, 32.h),
                                itemCount: items.length,
                                itemBuilder: (context, index) {
                                  final conv = items[index];
                                  return _ConversationTile(
                                    conversation: conv,
                                    onTap: () {
                                      context
                                          .pushNamed(
                                        AppRoutes.chat.name,
                                        pathParameters: {
                                          'conversationId': conv.id
                                        },
                                        extra: conv,
                                      )
                                          .then((_) => _fetchConversations());
                                    },
                                  );
                                },
                              ),
                      ),
                  ],
                );
              },
            ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Conversation tile ─────────────────────────────────────────────────────────

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.conversation,
    required this.onTap,
  });

  final Conversation conversation;
  final VoidCallback onTap;

  bool get _hasUnread => conversation.unreadCount > 0;

  @override
  Widget build(BuildContext context) {
    final name = conversation.providerName ?? 'Provider';
    final avatar = conversation.providerAvatarPath;
    final lastMsg = conversation.lastMessage ?? 'No messages yet';
    final time = _relativeTime(conversation.lastMessageAt);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: _hasUnread
              ? AppColors.primary.withValues(alpha: 0.05)
              : AppColors.background,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: _hasUnread
                ? AppColors.primary.withValues(alpha: 0.25)
                : AppColors.divider,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Avatar ────────────────────────────────────────────────────
            Stack(
              children: [
                CircleAvatar(
                  radius: 26.r,
                  backgroundColor: AppColors.splashShapeColor,
                  backgroundImage: avatar?.isNotEmpty == true
                      ? NetworkImage(avatar!)
                      : null,
                  child: avatar?.isNotEmpty != true
                      ? Text(
                          name[0].toUpperCase(),
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        )
                      : null,
                ),
                if (_hasUnread)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 12.r,
                      height: 12.r,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),

            SizedBox(width: 12.w),

            // ── Message info ──────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: _hasUnread
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (time.isNotEmpty) ...[
                        SizedBox(width: 8.w),
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: _hasUnread
                                ? AppColors.primary
                                : AppColors.textHint,
                            fontWeight: _hasUnread
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMsg,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: _hasUnread
                                ? AppColors.textPrimary
                                : AppColors.textHint,
                            fontWeight: _hasUnread
                                ? FontWeight.w500
                                : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_hasUnread) ...[
                        SizedBox(width: 8.w),
                        Container(
                          constraints: BoxConstraints(minWidth: 20.r),
                          height: 20.r,
                          padding: EdgeInsets.symmetric(horizontal: 6.w),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(50.r),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${conversation.unreadCount}',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: AppColors.textOnPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
