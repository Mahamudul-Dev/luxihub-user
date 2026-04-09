
import 'package:flutter/material.dart';

import '../../../../core/config/utils.dart';
import '../../../../core/theme/app_colors.dart';

class BookingSuccessSheet extends StatefulWidget {
  const BookingSuccessSheet({super.key, required this.providerName});

  final String providerName;

  @override
  State<BookingSuccessSheet> createState() => _BookingSuccessSheetState();
}

class _BookingSuccessSheetState extends State<BookingSuccessSheet> {
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
        borderRadius: BorderRadius.vertical(
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

          // Success icon
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

          // Title
          Text(
            'Booking Confirmed!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: Utils.defaultPadding / 2),

          // Subtitle
          Text(
            'Your booking with ${widget.providerName} has been placed successfully.',
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