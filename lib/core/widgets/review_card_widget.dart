import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../config/utils.dart';
import '../theme/app_colors.dart';

class ReviewCardWidget extends StatelessWidget {
  const ReviewCardWidget({
    super.key,

    // Reviewer identity
    required this.reviewerName,
    required this.reviewerAvatarUrl,
    required this.date,

    // Rating & comment
    required this.rating,
    required this.comment,

    // Styling
    this.backgroundColor,
    this.borderRadius,
    this.margin,
    this.padding,
    this.avatarRadius = 18,
    this.starSize,
    this.nameStyle,
    this.dateStyle,
    this.commentStyle,
  });

  /// Display name of the reviewer.
  final String reviewerName;

  /// URL of the reviewer's avatar image (asset or network).
  final String reviewerAvatarUrl;

  /// Date string shown below the name, e.g. "March 2025".
  final String date;

  /// Star rating value (0.0 – 5.0, half-star supported).
  final double rating;

  /// Body text of the review.
  final String comment;

  final Color? backgroundColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  /// Radius of the reviewer avatar circle.
  final double avatarRadius;

  /// Size of each rating star. Defaults to 14.sp.
  final double? starSize;

  final TextStyle? nameStyle;
  final TextStyle? dateStyle;
  final TextStyle? commentStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: Utils.defaultPadding),
      padding: padding ?? const EdgeInsets.all(Utils.defaultPadding),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surfaceBackground,
        borderRadius:
            BorderRadius.circular(borderRadius ?? Utils.defaultBorderRadius * 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Identity row
          Row(
            children: [
              CircleAvatar(
                radius: avatarRadius,
                backgroundColor: AppColors.inputBorder,
                backgroundImage: reviewerAvatarUrl.startsWith('http')
                    ? NetworkImage(reviewerAvatarUrl)
                    : AssetImage(reviewerAvatarUrl) as ImageProvider,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reviewerName,
                      style: nameStyle ??
                          Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                    ),
                    Text(
                      date,
                      style: dateStyle ??
                          Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textHint,
                              ),
                    ),
                  ],
                ),
              ),
              RatingBar.builder(
                initialRating: rating.clamp(0.0, 5.0),
                minRating: 1,
                ignoreGestures: true,
                itemCount: 5,
                itemSize: starSize ?? 14.sp,
                allowHalfRating: true,
                itemPadding: const EdgeInsets.symmetric(horizontal: 1),
                itemBuilder: (_, _) =>
                    const Icon(Icons.star, color: Colors.amber),
                onRatingUpdate: (_) {},
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Comment
          Text(
            comment,
            style: commentStyle ??
                Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
          ),
        ],
      ),
    );
  }
}
