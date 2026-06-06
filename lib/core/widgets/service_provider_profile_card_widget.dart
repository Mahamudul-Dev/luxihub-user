import 'package:flutter/material.dart';

import '../config/utils.dart';
import '../theme/app_colors.dart';

class ServiceProviderProfileCardWidget extends StatelessWidget {
  const ServiceProviderProfileCardWidget({
    super.key,

    // Identity
    required this.name,
    required this.serviceRate,

    // Photo
    this.imageProvider,
    this.imagePlaceholderColor,

    // Rating
    this.rating = 0.0,
    this.reviewCount = 0,
    this.ratingIcon,
    this.ratingColor,

    // Favourite
    this.isFavourite = false,
    this.onFavouriteTap,
    this.showFavouriteButton = true,
    this.favouriteIcon,
    this.favouriteActiveIcon,
    this.favouriteButtonColor,

    // Action
    this.onTap,

    // Styling
    this.borderRadius,
    this.padding,
    this.nameStyle,
    this.ratingStyle,
    this.rateStyle,
  });

  // ── Identity ──────────────────────────────────────────────────────────────

  /// Full display name of the service provider.
  final String name;

  /// Rate string shown at the bottom, e.g. "£20/hour".
  final String serviceRate;

  // ── Photo ─────────────────────────────────────────────────────────────────

  /// Background photo. Accepts any [ImageProvider] (asset, network, file…).
  final ImageProvider? imageProvider;

  /// Solid background color shown when [imageProvider] is null.
  final Color? imagePlaceholderColor;

  // ── Rating ────────────────────────────────────────────────────────────────

  /// Numeric rating value (0.0 – 5.0).
  final double rating;

  /// Number of reviews shown in parentheses.
  final int reviewCount;

  /// Override the default star icon.
  final Widget? ratingIcon;

  /// Color of the rating star. Defaults to [Colors.amber].
  final Color? ratingColor;

  // ── Favourite ─────────────────────────────────────────────────────────────

  /// Whether the card is currently marked as favourite.
  final bool isFavourite;

  /// Called when the favourite button is tapped.
  final VoidCallback? onFavouriteTap;

  /// Whether to show the favourite button at all.
  final bool showFavouriteButton;

  /// Icon shown when [isFavourite] is false.
  final Widget? favouriteIcon;

  /// Icon shown when [isFavourite] is true.
  final Widget? favouriteActiveIcon;

  /// Background color of the favourite circle avatar.
  final Color? favouriteButtonColor;

  // ── Action ────────────────────────────────────────────────────────────────

  /// Called when the whole card is tapped (e.g. open provider profile).
  final VoidCallback? onTap;

  // ── Styling ───────────────────────────────────────────────────────────────

  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final TextStyle? nameStyle;
  final TextStyle? ratingStyle;
  final TextStyle? rateStyle;

  // ── Helpers ───────────────────────────────────────────────────────────────

  String get _ratingLabel {
    final r = rating.toStringAsFixed(1);
    return reviewCount > 0 ? '$r ($reviewCount reviews)' : r;
  }

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? Utils.defaultBorderRadius;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(Utils.defaultPadding / 2),
        child: Stack(
          children: [
            // Background photo
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: imagePlaceholderColor ?? AppColors.primaryDark,
                borderRadius: BorderRadius.circular(radius),
                image: imageProvider != null
                    ? DecorationImage(
                        image: imageProvider!,
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
            ),

            // Favourite button
            if (showFavouriteButton)
              Positioned(
                top: Utils.defaultPadding / 2,
                right: Utils.defaultPadding / 2,
                child: GestureDetector(
                  onTap: onFavouriteTap,
                  child: CircleAvatar(
                    backgroundColor:
                        favouriteButtonColor ?? Colors.white70,
                    child: isFavourite
                        ? (favouriteActiveIcon ??
                            const Icon(
                              Icons.favorite,
                              color: AppColors.error,
                            ))
                        : (favouriteIcon ??
                            Icon(
                              Icons.favorite_border,
                              color: AppColors.primaryDark,
                            )),
                  ),
                ),
              ),

            // Info card — name, rating, rate
            Align(
              alignment: Alignment.bottomCenter,
              child: Card(
                margin: EdgeInsets.zero,
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(radius / 2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(Utils.defaultPadding / 2),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      Text(
                        name,
                        overflow: TextOverflow.ellipsis,
                        style: nameStyle ??
                            Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                      ),
              
                      const SizedBox(height: 4),
              
                      // Rating row
                      Row(
                        children: [
                          ratingIcon ??
                              Icon(
                                Icons.star,
                                color: ratingColor ?? Colors.amber,
                                size: 16,
                              ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _ratingLabel,
                              overflow: TextOverflow.ellipsis,
                              style: ratingStyle ??
                                  Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
              
                      // Rate
                      Text(
                        serviceRate,
                        style: rateStyle ??
                            Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
