import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/utils.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/domain/entities/service_provider_entity.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../rating_review/domain/entities/provider_review.dart';
import '../../../rating_review/domain/usecases/get_provider_reviews.dart';
import '../../../rating_review/presentation/pages/provider_reviews_page.dart';

class ServiceProviderProfilePage extends StatelessWidget {
  const ServiceProviderProfilePage({super.key, required this.provider});

  final ServiceProviderEntity provider;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // ── Hero image with gradient overlay ─────────────────────────────
          _HeroSection(provider: provider),

          // ── Draggable profile sheet ───────────────────────────────────────
          DraggableScrollableSheet(
            initialChildSize: 0.56,
            minChildSize: 0.56,
            maxChildSize: 0.95,
            builder: (context, scrollController) => _ProfileSheet(
              provider: provider,
              scrollController: scrollController,
            ),
          ),

          // ── Sticky Book Now bar ───────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _BookNowBar(provider: provider),
          ),
        ],
      ),
    );
  }
}

// ── Hero ──────────────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.provider});
  final ServiceProviderEntity provider;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 0.56.sh,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Provider photo
          provider.profileImageUrl.isNotEmpty
              ? Image.network(
                  provider.profileImageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      Container(color: AppColors.primaryDark),
                )
              : Container(
                  color: AppColors.primaryDark,
                  child: const Icon(Icons.person, size: 80, color: Colors.white30),
                ),

          // Gradient overlay (bottom half only)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.45, 1.0],
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.75),
                  ],
                ),
              ),
            ),
          ),

          // Name + location + badge overlay
          Positioned(
            left: Utils.defaultPadding * 1.5,
            right: Utils.defaultPadding * 1.5,
            bottom: Utils.defaultPadding * 1.5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Online / Offline badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: provider.isAvailable
                        ? Colors.green.shade600
                        : Colors.grey.shade600,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        provider.isAvailable ? 'Available Now' : 'Offline',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Name
                Text(
                  provider.fullName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),

                // Location
                if (provider.city.isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.white70, size: 14),
                      const SizedBox(width: 3),
                      Text(
                        provider.city,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Profile sheet ─────────────────────────────────────────────────────────────

class _ProfileSheet extends StatelessWidget {
  const _ProfileSheet({
    required this.provider,
    required this.scrollController,
  });

  final ServiceProviderEntity provider;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: ListView(
        controller: scrollController,
        padding: EdgeInsets.fromLTRB(
          Utils.defaultPadding * 1.5,
          Utils.defaultPadding,
          Utils.defaultPadding * 1.5,
          Utils.defaultPadding * 6, // space for sticky button
        ),
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: Utils.defaultPadding * 1.2),
              decoration: BoxDecoration(
                color: AppColors.inputBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── Stats row ───────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: Utils.defaultPadding,
              horizontal: Utils.defaultPadding / 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceBackground,
              borderRadius: BorderRadius.circular(Utils.defaultBorderRadius * 2),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                _StatItem(
                  icon: Icons.star_rounded,
                  iconColor: Colors.amber,
                  value: provider.rating.toStringAsFixed(1),
                  label: 'Rating',
                ),
                _verticalDivider,
                _StatItem(
                  icon: Icons.rate_review_rounded,
                  iconColor: AppColors.primary,
                  value: '${provider.reviewCount}',
                  label: 'Reviews',
                ),
                _verticalDivider,
                _StatItem(
                  icon: Icons.payments_rounded,
                  iconColor: AppColors.primaryLight,
                  value: provider.formattedRate,
                  label: 'Hourly',
                ),
              ],
            ),
          ),

          const SizedBox(height: Utils.defaultPadding * 1.5),

          // ── Rating bar ─────────────────────────────────────────────────
          Row(
            children: [
              RatingBarIndicator(
                rating: provider.rating.clamp(0.0, 5.0),
                itemBuilder: (_, _) =>
                    const Icon(Icons.star_rounded, color: Colors.amber),
                itemCount: 5,
                itemSize: 18.sp,
              ),
              const SizedBox(width: 8),
              Text(
                '${provider.rating.toStringAsFixed(1)}  ·  ${provider.reviewCount} reviews',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),

          const SizedBox(height: Utils.defaultPadding * 1.5),
          const Divider(height: 1),
          const SizedBox(height: Utils.defaultPadding * 1.5),

          // ── Skills ─────────────────────────────────────────────────────
          if (provider.skills.isNotEmpty) ...[
            _SectionHeader(title: 'Skills & Expertise'),
            const SizedBox(height: Utils.defaultPadding * 0.75),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: provider.skills
                  .map((skill) => _SkillChip(label: skill))
                  .toList(),
            ),
            const SizedBox(height: Utils.defaultPadding * 1.5),
            const Divider(height: 1),
            const SizedBox(height: Utils.defaultPadding * 1.5),
          ],

          // ── Service area info ──────────────────────────────────────────
          if (provider.city.isNotEmpty) ...[
            _SectionHeader(title: 'Service Area'),
            const SizedBox(height: Utils.defaultPadding * 0.75),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.location_on_rounded,
                      color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 10),
                Text(
                  provider.city,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: Utils.defaultPadding * 1.5),
            const Divider(height: 1),
            const SizedBox(height: Utils.defaultPadding * 1.5),
          ],

          // ── Reviews ────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SectionHeader(title: 'Customer Reviews'),
              TextButton(
                onPressed: () => context.pushNamed(
                  AppRoutes.providerReviews.name,
                  pathParameters: {'id': provider.id},
                  extra: ProviderReviewsArgs(
                    providerId: provider.id,
                    providerName: provider.fullName,
                  ),
                ),
                child: const Text('See All'),
              ),
            ],
          ),

          const SizedBox(height: Utils.defaultPadding / 2),

          FutureBuilder<List<ProviderReview>>(
            future: sl<GetProviderReviews>()(provider.id, limit: 5),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(Utils.defaultPadding),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: Utils.defaultPadding),
                  child: Text('Could not load reviews.',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.grey)),
                );
              }

              final reviews = snapshot.data ?? [];
              if (reviews.isEmpty) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: Utils.defaultPadding),
                  child: Column(
                    children: [
                      Icon(Icons.rate_review_outlined,
                          size: 40, color: Colors.grey.shade300),
                      const SizedBox(height: 8),
                      Text('No reviews yet.',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.grey)),
                    ],
                  ),
                );
              }

              return Column(
                children: reviews.map((r) => _ReviewCard(review: r)).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget get _verticalDivider => Container(
        width: 1,
        height: 40,
        color: AppColors.divider,
        margin: const EdgeInsets.symmetric(horizontal: 4),
      );
}

// ── Book Now sticky bar ────────────────────────────────────────────────────────

class _BookNowBar extends StatelessWidget {
  const _BookNowBar({required this.provider});
  final ServiceProviderEntity provider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        Utils.defaultPadding * 1.5,
        Utils.defaultPadding / 2,
        Utils.defaultPadding * 1.5,
        MediaQuery.of(context).padding.bottom + Utils.defaultPadding / 2,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rate chip
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                provider.formattedRate,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
              ),
              Text(
                'Starting rate',
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(width: Utils.defaultPadding),
          Expanded(
            child: ElevatedButton(
              onPressed: () =>
                  context.pushNamed(AppRoutes.postJob.name, extra: provider),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                    vertical: Utils.defaultPadding * 0.9),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(Utils.defaultBorderRadius * 1.5),
                ),
              ),
              child: const Text(
                'Book Now',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section header ─────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
    );
  }
}

// ── Stat item ──────────────────────────────────────────────────────────────────

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
          ),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ── Skill chip ────────────────────────────────────────────────────────────────

class _SkillChip extends StatelessWidget {
  const _SkillChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

// ── Review card with photo strip ──────────────────────────────────────────────

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});
  final ProviderReview review;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: Utils.defaultPadding),
      padding: const EdgeInsets.all(Utils.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.surfaceBackground,
        borderRadius: BorderRadius.circular(Utils.defaultBorderRadius * 1.5),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: avatar + name + date
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: review.clientAvatarPath != null &&
                        review.clientAvatarPath!.isNotEmpty
                    ? NetworkImage(review.clientAvatarPath!)
                    : null,
                backgroundColor: AppColors.divider,
                child: review.clientAvatarPath == null ||
                        review.clientAvatarPath!.isEmpty
                    ? const Icon(Icons.person, size: 18)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.clientName ?? 'Anonymous',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    RatingBarIndicator(
                      rating: review.score,
                      itemBuilder: (_, _) => const Icon(
                          Icons.star_rounded,
                          color: Colors.amber),
                      itemCount: 5,
                      itemSize: 13,
                    ),
                  ],
                ),
              ),
              Text(
                _formatDate(review.createdAt),
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey.shade500),
              ),
            ],
          ),

          // Comment
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.comment!,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textSecondary, height: 1.4),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          // Photo strip
          if (review.photoUrls.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: review.photoUrls.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) => GestureDetector(
                  onTap: () => _showFullImage(context, review.photoUrls, i),
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(Utils.defaultBorderRadius),
                    child: Image.network(
                      review.photoUrls[i],
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        width: 80,
                        height: 80,
                        color: AppColors.divider,
                        child: const Icon(Icons.broken_image_outlined,
                            color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showFullImage(
      BuildContext context, List<String> urls, int initialIndex) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(urls[initialIndex], fit: BoxFit.contain),
            ),
            Padding(
              padding: const EdgeInsets.all(4),
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const CircleAvatar(
                  backgroundColor: Colors.black54,
                  radius: 14,
                  child: Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}';
  }
}
