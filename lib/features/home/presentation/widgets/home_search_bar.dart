import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/config/utils.dart';
import '../../../../core/theme/app_colors.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({
    super.key,

    // Controller & state
    this.controller,
    this.focusNode,
    this.readOnly = false,
    this.autofocus = false,

    // Content
    this.hint = 'Search...',
    this.title,
    this.titleStyle,

    // Callbacks
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.onFilterTap,
    this.onClearTap,

    // Filter button
    this.showFilterButton = true,
    this.filterIcon,
    this.filterActiveIcon,
    this.filterActive = false,
    this.filterActiveColor,
    this.filterTooltip = 'Filter',

    // Search bar styling
    this.fillColor,
    this.borderRadius,
    this.height,
    this.searchIcon,
    this.suffixIcon,
    this.showClearButton = true,
    this.textStyle,
    this.hintStyle,
    this.contentPadding,
    this.elevation = 0,
  });

  // ── Controller & state ────────────────────────────────────────────────────

  final TextEditingController? controller;
  final FocusNode? focusNode;

  /// When true the field is not editable — tapping fires [onTap] instead
  /// (useful for navigating to a dedicated search page).
  final bool readOnly;
  final bool autofocus;

  // ── Content ───────────────────────────────────────────────────────────────

  /// Placeholder text inside the search field.
  final String hint;

  /// Optional heading shown above the search row (e.g. "Find the best…").
  final String? title;

  /// Style for [title]. Falls back to [headlineMedium] bold primary.
  final TextStyle? titleStyle;

  // ── Callbacks ─────────────────────────────────────────────────────────────

  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  /// Fired when the search bar is tapped (use with [readOnly]).
  final GestureTapCallback? onTap;

  /// Fired when the filter button is pressed.
  final VoidCallback? onFilterTap;

  /// Fired when the clear (×) button is pressed.
  final VoidCallback? onClearTap;

  // ── Filter button ─────────────────────────────────────────────────────────

  final bool showFilterButton;

  /// Icon shown when no filters are active.
  final Widget? filterIcon;

  /// Icon shown when [filterActive] is true.
  final Widget? filterActiveIcon;

  /// Highlights the filter button to signal active filters.
  final bool filterActive;

  /// Badge / highlight color when [filterActive] is true.
  final Color? filterActiveColor;

  final String filterTooltip;

  // ── Search bar styling ────────────────────────────────────────────────────

  /// Fill color of the search bar container.
  final Color? fillColor;

  final double? borderRadius;
  final double? height;

  /// Leading icon inside the search bar. Defaults to a search magnifier.
  final Widget? searchIcon;

  /// Optional trailing icon inside the search bar (before clear button).
  final Widget? suffixIcon;

  /// Show a clear (×) button when the field has text.
  final bool showClearButton;

  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final EdgeInsetsGeometry? contentPadding;

  /// Elevation of the search bar container.
  final double elevation;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? Utils.defaultBorderRadius;
    final barColor =
        fillColor ?? Theme.of(context).primaryColor.withAlpha(20);
    final activeColor = filterActiveColor ?? AppColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Optional title heading
        if (title != null) ...[
          Text(
            title!,
            style: titleStyle ??
                Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
          ),
          const SizedBox(height: Utils.defaultPadding),
        ],

        // Search row
        Row(
          children: [
            // Search bar
            Expanded(
              child: Material(
                elevation: elevation,
                borderRadius: BorderRadius.circular(radius),
                child: GestureDetector(
                  onTap: readOnly ? onTap : null,
                  child: Container(
                    height: height ?? 44.h,
                    padding: contentPadding ??
                        const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: barColor,
                      borderRadius: BorderRadius.circular(radius),
                    ),
                    child: Row(
                      children: [
                        // Leading search icon
                        searchIcon ??
                            Icon(
                              Icons.search,
                              size: 20,
                              color: Theme.of(context).primaryColor,
                            ),
                        const SizedBox(width: 8),

                        // Text field / hint
                        Expanded(
                          child: readOnly
                              ? Text(
                                  hint,
                                  style: hintStyle ??
                                      Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .primaryColor
                                                .withValues(alpha: 0.5),
                                          ),
                                )
                              : TextField(
                                  controller: controller,
                                  focusNode: focusNode,
                                  autofocus: autofocus,
                                  onChanged: onChanged,
                                  onSubmitted: onSubmitted,
                                  onTap: onTap,
                                  style: textStyle ??
                                      Theme.of(context).textTheme.bodyMedium,
                                  decoration: InputDecoration(
                                    hintText: hint,
                                    hintStyle: hintStyle ??
                                        Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .primaryColor
                                                  .withValues(alpha: 0.5),
                                            ),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    isDense: true,
                                    filled: false,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                        ),

                        // Optional suffix / clear button
                        if (suffixIcon case final icon?) icon,
                        if (showClearButton && controller != null)
                          ValueListenableBuilder(
                            valueListenable: controller!,
                            builder: (_, value, _) {
                              if (value.text.isEmpty) return const SizedBox();
                              return GestureDetector(
                                onTap: () {
                                  controller!.clear();
                                  onClearTap?.call();
                                  onChanged?.call('');
                                },
                                child: Icon(
                                  Icons.close,
                                  size: 18,
                                  color: AppColors.textHint,
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Filter button
            if (showFilterButton) ...[
              const SizedBox(width: 4),
              Tooltip(
                message: filterTooltip,
                child: IconButton(
                  onPressed: onFilterTap,
                  icon: filterActive
                      ? (filterActiveIcon ??
                          Icon(Icons.filter_list, color: activeColor))
                      : (filterIcon ??
                          Icon(
                            Icons.filter_list,
                            color: Theme.of(context).primaryColor,
                          )),
                  style: filterActive
                      ? IconButton.styleFrom(
                          backgroundColor: activeColor.withAlpha(20),
                        )
                      : null,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
