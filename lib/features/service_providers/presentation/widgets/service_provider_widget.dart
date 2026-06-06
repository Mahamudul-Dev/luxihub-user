import 'package:flutter/material.dart';

import '../../../../core/domain/entities/service_provider_entity.dart';
import '../../../../core/theme/app_colors.dart';

class ServiceProviderWidget extends StatelessWidget {
  final ServiceProviderEntity provider;
  final bool isFavourite;
  final VoidCallback? onFavouriteTap;
  final VoidCallback? onTap;

  const ServiceProviderWidget({
    super.key,
    required this.provider,
    this.isFavourite = false,
    this.onFavouriteTap,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(provider.profileImageUrl),
                    backgroundColor: AppColors.primaryDark,
                  ),
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: provider.isAvailable ? Colors.green : Colors.grey,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.fullName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      provider.category,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(
                          '${provider.rating.toStringAsFixed(1)} (${provider.reviewCount})',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const Spacer(),
                        Text(
                          provider.formattedRate,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  isFavourite ? Icons.favorite : Icons.favorite_border,
                  color: isFavourite ? Colors.red : Colors.grey,
                ),
                onPressed: onFavouriteTap,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
