import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:luxihub_user/core/domain/entities/service_provider_entity.dart';

import '../../../../core/config/utils.dart';
import '../../../../core/enum/job_request_enum.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/map_placeholder_widget.dart';
import '../../../../core/widgets/status_badge.dart';
import '../bloc/job_request_bloc.dart';
import '../widgets/job_complete_sheet.dart';

class JobRequestDetailsPage extends StatelessWidget {
  final ServiceProviderEntity provider;
  const JobRequestDetailsPage({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => JobRequestBloc()..add(const JobRequestStarted()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Details'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(Utils.defaultPadding),
          child: Column(
            children: [
              // provider info tile
              BlocBuilder<JobRequestBloc, JobRequestState>(
                builder: (context, state) {
                  final status = state is JobRequestStatusUpdated
                      ? state.status
                      : JobRequestStatus.waiting;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(provider.profileImageUrl),
                    ),
                    title: Text(
                      provider.fullName,
                      style: Theme.of(context).textTheme.titleLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      provider.category,
                      style: Theme.of(context).textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: StatusBadge(status: status, key: ValueKey(status)),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Utils.defaultBorderRadius),
                    ),
                    tileColor: AppColors.divider,
                  );
                },
              ),

              // action button
              SizedBox(height: Utils.defaultPadding),
              BlocBuilder<JobRequestBloc, JobRequestState>(
                builder: (context, state) {
                  final status = state is JobRequestStatusUpdated
                      ? state.status
                      : JobRequestStatus.waiting;
                  final isAccepted = status == JobRequestStatus.accepted;

                  return ElevatedButton(
                    onPressed: () async {
                      if (isAccepted) {
                        await showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          isDismissible: false,
                          builder: (_) => JobCompleteSheet(
                            providerName: provider.fullName,
                          ),
                        );
                        if (context.mounted) {
                          context.goNamed(
                            AppRoutes.rating.name,
                            extra: provider,
                          );
                        }
                      } else {
                        // TODO: Implement cancel request logic (e.g. call API, update state)
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
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        isAccepted ? 'Mark As Completed' : 'Cancel Request',
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

              // Map with location pin
              SizedBox(height: Utils.defaultPadding),
              Expanded(child: MapPlaceholderWidget()),
            ],
          ),
        ),
      ),
    );
  }
}

