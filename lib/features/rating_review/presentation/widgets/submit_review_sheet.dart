import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/utils.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/rating_bloc.dart';

class SubmitReviewSheet extends StatelessWidget {
  const SubmitReviewSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RatingBloc, RatingState>(
      listenWhen: (prev, curr) =>
          curr.status == RatingStatus.submitted &&
          prev.status != RatingStatus.submitted,
      listener: (context, state) async {
        await Future.delayed(const Duration(seconds: 2));
        if (context.mounted) {
          Navigator.of(context).pop();
          context.goNamed(AppRoutes.home.name);
        }
      },
      builder: (context, state) {
        final isSubmitting = state.status == RatingStatus.submitting;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: Utils.defaultPadding * 2,
            vertical: Utils.defaultPadding * 2,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(Utils.defaultBorderRadius * 4),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: Utils.defaultPadding * 1.5),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: isSubmitting
                    ? _LoadingContent(key: const ValueKey('loading'))
                    : _SuccessContent(key: const ValueKey('success')),
              ),

              const SizedBox(height: Utils.defaultPadding * 2),
            ],
          ),
        );
      },
    );
  }
}

class _LoadingContent extends StatelessWidget {
  const _LoadingContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CircularProgressIndicator(color: Colors.white),
        const SizedBox(height: Utils.defaultPadding),
        Text(
          'Submitting your review...',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _SuccessContent extends StatelessWidget {
  const _SuccessContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(Utils.defaultPadding),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_outline_rounded,
            color: Colors.white,
            size: 48,
          ),
        ),
        const SizedBox(height: Utils.defaultPadding),
        Text(
          'Review Submitted!',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: Utils.defaultPadding / 2),
        Text(
          'Thank you for your feedback. It helps others find great service providers.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.85),
              ),
        ),
      ],
    );
  }
}
