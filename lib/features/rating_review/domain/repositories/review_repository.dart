import '../entities/provider_review.dart';

abstract interface class ReviewRepository {
  Future<void> submitReview({
    required String jobId,
    required String clientId,
    required String providerId,
    required double score,
    String? comment,
    List<String> photoPaths,
  });

  /// Returns the review submitted for [jobId], or null if none exists yet.
  Future<({double score, String? comment})?> getJobReview(String jobId);

  Future<List<ProviderReview>> getProviderReviews(
    String providerId, {
    int? limit,
  });
}
