import 'package:flutter/material.dart';

import '../config/utils.dart';
import '../enum/job_request_enum.dart';
import '../theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final JobRequestStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      JobRequestStatus.pending => ('Waiting for response', Colors.amber),
      JobRequestStatus.accepted => ('Accepted', AppColors.primary),
      JobRequestStatus.rejected => ('Rejected', AppColors.error),
      JobRequestStatus.awaitingPaymentConfirmation =>
        ('Awaiting Payment', Colors.orange),
      JobRequestStatus.awaitingOfflineConfirmation =>
        ('Cash Pending', Colors.blueGrey),
      JobRequestStatus.completed => ('Completed', Colors.green),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Utils.defaultPadding,
        vertical: Utils.defaultPadding / 2,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(Utils.defaultBorderRadius),
      ),
      child: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: Colors.white),
      ),
    );
  }
}
