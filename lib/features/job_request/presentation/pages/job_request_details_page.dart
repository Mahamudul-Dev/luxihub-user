import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/utils.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/domain/entities/job_request.dart';
import '../../../../core/enum/job_request_enum.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../features/chat/domain/usecases/get_or_create_conversation.dart';
import '../../../../features/rating_review/domain/usecases/get_job_review.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../bloc/job_request_bloc.dart';
import '../widgets/job_complete_sheet.dart';
import '../widgets/job_tracking_map.dart';
import '../widgets/payment_method_sheet.dart';

class JobRequestDetailsPage extends StatefulWidget {
  final JobRequest job;
  const JobRequestDetailsPage({super.key, required this.job});

  @override
  State<JobRequestDetailsPage> createState() => _JobRequestDetailsPageState();
}

class _JobRequestDetailsPageState extends State<JobRequestDetailsPage> {
  bool _chatLoading = false;
  bool _offlineDialogShown = false;
  ({double score, String? comment})? _review;
  bool _reviewLoaded = false;

  @override
  void initState() {
    super.initState();
    context.read<JobRequestBloc>().add(JobStatusWatchStarted(widget.job));
    if (widget.job.isCompleted) _fetchReview();
  }

  Future<void> _fetchReview() async {
    if (_reviewLoaded) return;
    try {
      final review = await sl<GetJobReview>()(widget.job.id);
      if (mounted) setState(() { _review = review; _reviewLoaded = true; });
    } catch (e) {
      debugPrint('getJobReview error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load review: $e')),
        );
      }
    }
  }

  Future<void> _openChat() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    final providerId = widget.job.providerId;
    if (providerId == null) return;

    setState(() => _chatLoading = true);
    try {
      final conversation = await sl<GetOrCreateConversation>()(
        clientId: authState.user.id,
        providerId: providerId,
        jobRequestId: widget.job.id,
      );
      if (mounted) {
        context.pushNamed(
          AppRoutes.chat.name,
          pathParameters: {'conversationId': conversation.id},
          extra: conversation,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Could not open chat: $e'),
              backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _chatLoading = false);
    }
  }

  void _openPaymentSheet(BuildContext ctx, String clientId) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false,
      builder: (_) => BlocProvider.value(
        value: ctx.read<JobRequestBloc>(),
        child: PaymentMethodSheet(job: widget.job, clientId: clientId),
      ),
    );
  }

  void _showOfflineWaitingDialog() {
    if (_offlineDialogShown) return;
    _offlineDialogShown = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => BlocProvider.value(
        value: context.read<JobRequestBloc>(),
        child: const _OfflineWaitingDialog(),
      ),
    ).then((_) => _offlineDialogShown = false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<JobRequestBloc, JobRequestState>(
      listener: (context, state) {
        if (state is JobRequestCancelled) {
          context.pop();
        } else if (state is JobRequestAwaitingOfflineConfirmation) {
          _showOfflineWaitingDialog();
        } else if (state is JobRequestCompleted) {
          // Close any open offline dialog before showing the sheet
          if (_offlineDialogShown) {
            Navigator.of(context).pop();
          }
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            isDismissible: false,
            builder: (_) => JobCompleteSheet(
              providerName: widget.job.providerName ?? 'Provider',
              onRate: () {
                Navigator.of(context).pop();
                context.goNamed(AppRoutes.rating.name, extra: widget.job);
              },
            ),
          );
        } else if (state is JobRequestError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: AppColors.error,
          ));
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Job Details')),
        floatingActionButton: widget.job.providerId != null
            ? FloatingActionButton.extended(
                onPressed: _chatLoading ? null : _openChat,
                backgroundColor: AppColors.primary,
                icon: _chatLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.chat_bubble_outline,
                        color: Colors.white),
                label: Text(
                  _chatLoading ? 'Opening...' : 'Chat',
                  style: const TextStyle(color: Colors.white),
                ),
              )
            : null,
        body: Padding(
          padding: const EdgeInsets.all(Utils.defaultPadding),
          child: Column(
            children: [
              // ── Provider tile with status badge ──────────────────────────
              BlocBuilder<JobRequestBloc, JobRequestState>(
                builder: (context, state) {
                  final status = state is JobRequestWatching
                      ? state.status
                      : JobRequestStatusX.fromString(widget.job.status);
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: widget.job.providerAvatarPath != null
                          ? NetworkImage(widget.job.providerAvatarPath!)
                          : null,
                      child: widget.job.providerAvatarPath == null
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    title: Text(
                      widget.job.providerName ?? 'Provider',
                      style: Theme.of(context).textTheme.titleLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      widget.job.category,
                      style: Theme.of(context).textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: StatusBadge(status: status, key: ValueKey(status)),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(Utils.defaultBorderRadius),
                    ),
                    tileColor: AppColors.divider,
                  );
                },
              ),

              const SizedBox(height: Utils.defaultPadding),

              // ── Action button ────────────────────────────────────────────
              BlocBuilder<JobRequestBloc, JobRequestState>(
                builder: (context, state) {
                  final status = state is JobRequestWatching
                      ? state.status
                      : JobRequestStatusX.fromString(widget.job.status);

                  final isAccepted = status == JobRequestStatus.accepted;
                  final isCompleted = status == JobRequestStatus.completed;
                  final isAwaitingOffline =
                      status == JobRequestStatus.awaitingOfflineConfirmation;
                  final isLoading = state is JobRequestLoading;

                  // Hide button when completed or waiting for handyman cash confirm
                  if (isCompleted || isAwaitingOffline) {
                    return const SizedBox.shrink();
                  }

                  final authState = context.read<AuthBloc>().state;
                  final clientId = authState is AuthAuthenticated
                      ? authState.user.id
                      : '';

                  return ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            if (isAccepted) {
                              _openPaymentSheet(context, clientId);
                            } else {
                              context
                                  .read<JobRequestBloc>()
                                  .add(JobCancelRequested(widget.job.id));
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isAccepted ? AppColors.primary : AppColors.error,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(Utils.defaultBorderRadius),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: Utils.defaultPadding * 2,
                        vertical: Utils.defaultPadding,
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              isAccepted
                                  ? 'Mark As Completed'
                                  : 'Cancel Request',
                              key: ValueKey(isAccepted),
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(color: AppColors.background),
                            ),
                          ),
                  );
                },
              ),

              const SizedBox(height: Utils.defaultPadding),

              // ── Map OR completion view ───────────────────────────────────
              BlocBuilder<JobRequestBloc, JobRequestState>(
                builder: (context, state) {
                  final status = state is JobRequestWatching
                      ? state.status
                      : JobRequestStatusX.fromString(widget.job.status);
                  final isCompleted = status == JobRequestStatus.completed;

                  if (isCompleted) {
                    if (!_reviewLoaded) {
                      WidgetsBinding.instance
                          .addPostFrameCallback((_) => _fetchReview());
                    }
                    return Expanded(
                      child: _CompletedView(
                        providerName: widget.job.providerName,
                        review: _review,
                        onRetryReview: () {
                          setState(() => _reviewLoaded = false);
                          _fetchReview();
                        },
                      ),
                    );
                  }

                  return Expanded(child: JobTrackingMap(job: widget.job));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Offline waiting dialog ─────────────────────────────────────────────────────

class _OfflineWaitingDialog extends StatelessWidget {
  const _OfflineWaitingDialog();

  @override
  Widget build(BuildContext context) {
    return BlocListener<JobRequestBloc, JobRequestState>(
      listener: (context, state) {
        if (state is JobRequestCompleted || state is JobRequestError) {
          Navigator.of(context).pop();
        }
      },
      child: AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.hourglass_top_rounded,
                  size: 48, color: Colors.blueGrey.shade600),
            ),
            const SizedBox(height: 16),
            Text(
              'Waiting for Handyman',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'The handyman needs to confirm that they received your cash payment.\n\nThe job will be marked complete once they confirm.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            const LinearProgressIndicator(),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ── Completed view ─────────────────────────────────────────────────────────────

class _CompletedView extends StatelessWidget {
  final String? providerName;
  final ({double score, String? comment})? review;
  final VoidCallback onRetryReview;

  const _CompletedView({
    this.providerName,
    this.review,
    required this.onRetryReview,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: Utils.defaultPadding * 2),

          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_rounded,
              color: Colors.green.shade600,
              size: 64,
            ),
          ),

          const SizedBox(height: Utils.defaultPadding),

          Text(
            'Job Completed!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Great! ${providerName ?? 'The provider'} has completed your request.',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey.shade600),
          ),

          if (review != null) ...[
            const SizedBox(height: Utils.defaultPadding * 2),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(Utils.defaultPadding),
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius:
                    BorderRadius.circular(Utils.defaultBorderRadius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.rate_review_rounded, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Your Review',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  RatingBarIndicator(
                    rating: review!.score,
                    itemBuilder: (_, _) =>
                        const Icon(Icons.star_rounded, color: Colors.amber),
                    itemCount: 5,
                    itemSize: 24,
                  ),
                  if (review!.comment != null &&
                      review!.comment!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      '"${review!.comment}"',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey.shade700,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: Utils.defaultPadding * 2),
            Text(
              'No review submitted yet.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onRetryReview,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Retry'),
            ),
          ],

          const SizedBox(height: Utils.defaultPadding * 2),
        ],
      ),
    );
  }
}
