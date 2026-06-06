import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/config/utils.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/domain/entities/job_request.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../domain/usecases/submit_review.dart';
import '../bloc/rating_bloc.dart';
import '../widgets/photo_picker_grid.dart';
import '../widgets/submit_review_sheet.dart';

class RatingPage extends StatelessWidget {
  final JobRequest job;
  const RatingPage({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RatingBloc(
        authBloc: context.read<AuthBloc>(),
        submitReview: sl<SubmitReview>(),
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text('Rating & Review')),
        body: Builder(
          builder: (context) => SingleChildScrollView(
            padding: const EdgeInsets.all(Utils.defaultPadding),
            child: Column(
              children: [
                // Provider info tile
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: job.providerAvatarPath != null
                        ? NetworkImage(job.providerAvatarPath!)
                        : null,
                    child: job.providerAvatarPath == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text(
                    job.providerName ?? 'Provider',
                    style: Theme.of(context).textTheme.titleLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    job.category,
                    style: Theme.of(context).textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        job.providerRating.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(Utils.defaultBorderRadius),
                  ),
                  tileColor: AppColors.divider,
                ),

                const SizedBox(height: Utils.defaultPadding * 2),

                // Rating bar
                RatingBar.builder(
                  initialRating: 0.0,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemSize: 36.sp,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 2),
                  itemBuilder: (_, _) =>
                      const Icon(Icons.star, color: Colors.amber),
                  onRatingUpdate: (score) =>
                      context.read<RatingBloc>().add(RatingScoreChanged(score)),
                ),

                const SizedBox(height: Utils.defaultPadding * 2),

                // Review text field
                Container(
                  padding: const EdgeInsets.all(Utils.defaultPadding),
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius:
                        BorderRadius.circular(Utils.defaultBorderRadius),
                  ),
                  child: TextField(
                    maxLines: 5,
                    onChanged: (value) => context
                        .read<RatingBloc>()
                        .add(RatingCommentChanged(value)),
                    decoration: const InputDecoration(
                      hintText: 'Tell us about your experience...',
                      filled: true,
                      fillColor: AppColors.divider,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),

                const SizedBox(height: Utils.defaultPadding * 2),

                const PhotoPickerGrid(),

                const SizedBox(height: Utils.defaultPadding * 3),

                ElevatedButton(
                  onPressed: () {
                    final score = context.read<RatingBloc>().state.score;
                    if (score == 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a star rating.')),
                      );
                      return;
                    }
                    context.read<RatingBloc>().add(RatingSubmitted(
                          jobId: job.id,
                          providerId: job.providerId ?? '',
                        ));
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isDismissible: false,
                      builder: (_) => BlocProvider.value(
                        value: context.read<RatingBloc>(),
                        child: const SubmitReviewSheet(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: Utils.defaultPadding * 2,
                      vertical: Utils.defaultPadding,
                    ),
                  ),
                  child: const Text('Submit Review'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
