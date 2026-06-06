import '../../../../core/domain/entities/job_request.dart';

class JobRequestModel {
  static JobRequest fromJson(Map<String, dynamic> json) {
    // Optional embedded provider (from profiles JOIN)
    final providerJson = json['provider'] as Map<String, dynamic>?;
    final rawReviews = providerJson?['reviews'] as List? ?? [];
    final scores = rawReviews
        .map((r) => ((r as Map<String, dynamic>)['score'] as num).toDouble())
        .toList();
    final reviewCount = scores.length;
    final avgRating =
        reviewCount > 0 ? scores.reduce((a, b) => a + b) / reviewCount : 0.0;

    return JobRequest(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      providerId: json['provider_id'] as String?,
      category: json['category'] as String,
      description: json['description'] as String,
      status: json['status'] as String,
      clientLat: (json['client_lat'] as num).toDouble(),
      clientLng: (json['client_lng'] as num).toDouble(),
      amount: (json['amount'] as num?)?.toDouble(),
      postedAt: DateTime.parse(json['posted_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      providerName: providerJson?['name'] as String?,
      providerAvatarPath: providerJson?['avatar_path'] as String?,
      providerRating: avgRating,
      providerReviewCount: reviewCount,
      providerStripeAccountId: providerJson?['stripe_account_id'] as String?,
      providerHourlyRate: (providerJson?['hourly_rate'] as num?)?.toDouble(),
    );
  }
}
