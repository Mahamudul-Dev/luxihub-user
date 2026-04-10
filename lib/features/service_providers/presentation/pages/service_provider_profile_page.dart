import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:go_router/go_router.dart';

import '../../../../core/config/utils.dart';
import '../../../../core/domain/entities/service_provider_entity.dart';
import '../../../../core/dummy/dummy.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/review_card_widget.dart';
import '../widgets/booking_status_sheet.dart';


class ServiceProviderProfilePage extends StatelessWidget {
  const ServiceProviderProfilePage({super.key, required this.provider});

  final ServiceProviderEntity provider;

  Future<void> _showBookingSuccess(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (_) => BookingSuccessSheet(providerName: provider.fullName),
    );
    if (context.mounted) {
      context.goNamed(AppRoutes.jobRequestDetails.name, extra: provider);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              backgroundColor: Colors.grey[300],
              backgroundImage: NetworkImage(Dummy.users[0].profileImageUrl),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // ── Full-screen background photo ─────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 0.55.sh,
            child: Image.network(
              provider.profileImageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: AppColors.primaryDark),
            ),
          ),

          // ── Draggable details sheet ──────────────────────────────────────
          DraggableScrollableSheet(
            initialChildSize: 0.55,
            minChildSize: 0.55,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(Utils.defaultBorderRadius * 5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: Utils.defaultPadding * 1.5,
                    vertical: Utils.defaultPadding,
                  ),
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: Utils.defaultPadding),
                        decoration: BoxDecoration(
                          color: AppColors.inputBorder,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Name
                    Text(
                      provider.fullName,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                    ),

                    const SizedBox(height: 4),

                    // Category + experience
                    Text(
                      '${provider.category}  •  ${provider.yearsOfExperience} yrs experience',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),

                    const SizedBox(height: Utils.defaultPadding / 2),

                    // Rating row
                    Row(
                      children: [
                        RatingBar.builder(
                          initialRating: provider.rating.clamp(0.0, 5.0),
                          minRating: 1,
                          ignoreGestures: true,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemSize: 18.sp,
                          itemPadding: const EdgeInsets.symmetric(horizontal: 2),
                          itemBuilder: (_, _) =>
                              const Icon(Icons.star, color: Colors.amber),
                          onRatingUpdate: (_) {},
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${provider.rating.toStringAsFixed(1)}  (${provider.reviewCount} reviews)',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),

                    const SizedBox(height: Utils.defaultPadding),
                    const Divider(),
                    const SizedBox(height: Utils.defaultPadding / 2),

                    // Skills chips
                    Text(
                      'Skills',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    const SizedBox(height: Utils.defaultPadding / 2),
                    Wrap(
                      spacing: Utils.defaultPadding / 2,
                      runSpacing: Utils.defaultPadding / 2,
                      children: provider.skills
                          .map((skill) => Chip(
                                side: BorderSide.none,
                                backgroundColor:
                                    AppColors.primaryLight.withAlpha(200),
                                label: Text(
                                  skill,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      ),
                                ),
                              ))
                          .toList(),
                    ),

                    const SizedBox(height: Utils.defaultPadding),
                    const Divider(),
                    const SizedBox(height: Utils.defaultPadding / 2),

                    // Rate
                    Row(
                      children: [
                        Text(
                          'Rate',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          provider.formattedRate,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),

                    const SizedBox(height: Utils.defaultPadding),
                    const Divider(),
                    const SizedBox(height: Utils.defaultPadding / 2),

                    // Reviews section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Reviews',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                        ),
                        Text(
                          '${provider.reviewCount} total',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),

                    const SizedBox(height: Utils.defaultPadding / 2),

                    ...Dummy.reviews.map((r) => ReviewCardWidget(
                          reviewerName: r.reviewerName,
                          reviewerAvatarUrl: r.reviewerAvatarUrl,
                          date: r.date,
                          rating: r.rating,
                          comment: r.comment,
                        )),

                    const SizedBox(height: Utils.defaultPadding * 4),
                  ],
                ),
              );
            },
          ),

          // ── Floating Book Now button (always visible) ────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                Utils.defaultPadding * 1.5,
                Utils.defaultPadding / 2,
                Utils.defaultPadding * 1.5,
                Utils.defaultPadding,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 12,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () => _showBookingSuccess(context),
                child: const Text('Book Now'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

