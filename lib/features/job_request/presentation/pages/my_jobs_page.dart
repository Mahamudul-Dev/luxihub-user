import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/utils.dart';
import '../../../../core/domain/entities/job_request.dart';
import '../../../../core/enum/job_request_enum.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../bloc/job_request_bloc.dart';

class MyJobsPage extends StatefulWidget {
  const MyJobsPage({super.key});

  @override
  State<MyJobsPage> createState() => _MyJobsPageState();
}

class _MyJobsPageState extends State<MyJobsPage> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<JobRequestBloc>().add(MyJobsRequested(authState.user.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Jobs')),
      body: BlocConsumer<JobRequestBloc, JobRequestState>(
        listener: (context, state) {
          if (state is JobRequestError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ));
          }
        },
        builder: (context, state) {
          if (state is MyJobsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MyJobsLoaded) {
            if (state.jobs.isEmpty) {
              return const Center(child: Text('No jobs yet.'));
            }
            return RefreshIndicator(
              onRefresh: () async {
                final authState = context.read<AuthBloc>().state;
                if (authState is AuthAuthenticated) {
                  context
                      .read<JobRequestBloc>()
                      .add(MyJobsRequested(authState.user.id));
                }
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(Utils.defaultPadding),
                itemCount: state.jobs.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: Utils.defaultPadding / 2),
                itemBuilder: (context, index) {
                  final job = state.jobs[index];
                  return _JobCard(job: job);
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

class _JobCard extends StatelessWidget {
  final JobRequest job;
  const _JobCard({required this.job});

  @override
  Widget build(BuildContext context) {
    final status = JobRequestStatusX.fromString(job.status);

    return Card(
      child: ListTile(
        onTap: () async {
          await context.pushNamed(
            AppRoutes.jobRequestDetails.name,
            extra: job,
          );
          if (context.mounted) {
            final authState = context.read<AuthBloc>().state;
            if (authState is AuthAuthenticated) {
              context
                  .read<JobRequestBloc>()
                  .add(MyJobsRequested(authState.user.id));
            }
          }
        },
        leading: CircleAvatar(
          backgroundColor: AppColors.divider,
          backgroundImage: job.providerAvatarPath != null
              ? NetworkImage(job.providerAvatarPath!)
              : null,
          child: job.providerAvatarPath == null
              ? const Icon(Icons.person, color: AppColors.textSecondary)
              : null,
        ),
        title: Text(
          job.providerName ?? 'Unassigned',
          style: Theme.of(context).textTheme.titleMedium,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          job.category,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: AppColors.textSecondary),
        ),
        trailing: StatusBadge(status: status),
      ),
    );
  }
}
