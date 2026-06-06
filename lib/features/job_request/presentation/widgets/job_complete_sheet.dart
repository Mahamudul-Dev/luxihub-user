import 'package:flutter/material.dart';

import '../../../../core/config/utils.dart';
import '../../../../core/theme/app_colors.dart';

class JobCompleteSheet extends StatelessWidget {
  const JobCompleteSheet({
    super.key,
    required this.providerName,
    required this.onRate,
  });

  final String providerName;
  final VoidCallback onRate;

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
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: Utils.defaultPadding * 1.5),
          Container(
            padding: const EdgeInsets.all(Utils.defaultPadding),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.favorite_rounded,
                color: Colors.white, size: 48),
          ),
          const SizedBox(height: Utils.defaultPadding),
          Text(
            'Thank You!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: Utils.defaultPadding / 2),
          Text(
            'We hope $providerName did a great job.\nYour feedback helps others find the best providers.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
          ),
          const SizedBox(height: Utils.defaultPadding * 2),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onRate,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(Utils.defaultBorderRadius),
                ),
                padding: const EdgeInsets.symmetric(
                    vertical: Utils.defaultPadding),
              ),
              child: const Text('Rate Now',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: Utils.defaultPadding),
        ],
      ),
    );
  }
}
