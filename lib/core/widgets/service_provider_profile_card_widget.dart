import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';

class ServiceProviderProfileCardWidget extends StatelessWidget {
  const ServiceProviderProfileCardWidget({
    super.key,
    required this.name,
    required this.serviceRate,
    this.imageProvider,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isFavourite = false,
    this.onFavouriteTap,
    this.showFavouriteButton = true,
    this.onTap,
  });

  final String name;
  final String serviceRate;
  final ImageProvider? imageProvider;
  final double rating;
  final int reviewCount;
  final bool isFavourite;
  final VoidCallback? onFavouriteTap;
  final bool showFavouriteButton;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          color: AppColors.background,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Photo ─────────────────────────────────────────────────────
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Background photo
                  Container(
                    color: AppColors.splashShapeColor,
                    child: imageProvider != null
                        ? Image(image: imageProvider!, fit: BoxFit.cover)
                        : Center(
                            child: Icon(
                              Icons.person_rounded,
                              size: 48.r,
                              color: AppColors.primary,
                            ),
                          ),
                  ),

                  // Gradient overlay at bottom of image
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 40.h,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Favourite button
                  if (showFavouriteButton)
                    Positioned(
                      top: 8.r,
                      right: 8.r,
                      child: GestureDetector(
                        onTap: onFavouriteTap,
                        child: Container(
                          width: 32.r,
                          height: 32.r,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isFavourite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: isFavourite
                                ? AppColors.error
                                : AppColors.textHint,
                            size: 16.r,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Info ──────────────────────────────────────────────────────
            Container(
              width: double.infinity,
              color: AppColors.background,
              padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.star_rounded,
                          color: AppColors.accent, size: 14.r),
                      SizedBox(width: 3.w),
                      Text(
                        rating.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (reviewCount > 0) ...[
                        Text(
                          ' ($reviewCount)',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    serviceRate,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
