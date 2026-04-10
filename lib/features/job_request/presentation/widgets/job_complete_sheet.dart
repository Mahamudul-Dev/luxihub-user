import 'package:flutter/material.dart';

import '../../../../core/config/utils.dart';
import '../../../../core/theme/app_colors.dart';

class JobCompleteSheet extends StatefulWidget {
  const JobCompleteSheet({super.key, required this.providerName});

  final String providerName;

  @override
  State<JobCompleteSheet> createState() => _JobCompleteSheetState();
}

class _JobCompleteSheetState extends State<JobCompleteSheet> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
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

          // Thank you icon
          Container(
            padding: const EdgeInsets.all(Utils.defaultPadding),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: Colors.white,
              size: 48,
            ),
          ),
          const SizedBox(height: Utils.defaultPadding),

          // Title
          Text(
            'Thank You!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: Utils.defaultPadding / 2),

          // Subtitle
          Text(
            'We hope ${widget.providerName} did a great job. Your feedback helps others find the best service providers.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
          ),
          const SizedBox(height: Utils.defaultPadding * 2),
        ],
      ),
    );
  }
}
