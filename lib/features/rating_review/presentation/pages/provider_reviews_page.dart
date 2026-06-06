import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../../../core/config/utils.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/provider_review.dart';
import '../../domain/usecases/get_provider_reviews.dart';

class ProviderReviewsArgs {
  final String providerId;
  final String providerName;
  const ProviderReviewsArgs({
    required this.providerId,
    required this.providerName,
  });
}

class ProviderReviewsPage extends StatefulWidget {
  final ProviderReviewsArgs args;
  const ProviderReviewsPage({super.key, required this.args});

  @override
  State<ProviderReviewsPage> createState() => _ProviderReviewsPageState();
}

class _ProviderReviewsPageState extends State<ProviderReviewsPage> {
  late Future<List<ProviderReview>> _future;

  @override
  void initState() {
    super.initState();
    _future = sl<GetProviderReviews>()(widget.args.providerId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.args.providerName} — Reviews')),
      body: FutureBuilder<List<ProviderReview>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Failed to load reviews',
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => setState(() {
                      _future = sl<GetProviderReviews>()(widget.args.providerId);
                    }),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final reviews = snapshot.data ?? [];
          if (reviews.isEmpty) {
            return const Center(child: Text('No reviews yet.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(Utils.defaultPadding),
            itemCount: reviews.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) => _ReviewTile(review: reviews[i]),
          );
        },
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final ProviderReview review;
  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Utils.defaultPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundImage: review.clientAvatarPath != null
                ? NetworkImage(review.clientAvatarPath!)
                : null,
            backgroundColor: AppColors.divider,
            child: review.clientAvatarPath == null
                ? const Icon(Icons.person, size: 22)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        review.clientName ?? 'Anonymous',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      _formatDate(review.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade500,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                RatingBarIndicator(
                  rating: review.score,
                  itemBuilder: (_, _) =>
                      const Icon(Icons.star_rounded, color: Colors.amber),
                  itemCount: 5,
                  itemSize: 16,
                ),
                if (review.comment != null && review.comment!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    review.comment!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],

                // Photo strip
                if (review.photoUrls.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 90,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: review.photoUrls.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, i) => GestureDetector(
                        onTap: () => _showFullImage(context, review.photoUrls, i),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(Utils.defaultBorderRadius),
                          child: Image.network(
                            review.photoUrls[i],
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              width: 90,
                              height: 90,
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
          ),
        ],
      ),
    );
  }

  void _showFullImage(BuildContext context, List<String> urls, int index) {
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
              child: Image.network(urls[index], fit: BoxFit.contain),
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
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}
