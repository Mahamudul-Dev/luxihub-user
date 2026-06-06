import '../../domain/entities/provider_review.dart';
import '../../domain/repositories/review_repository.dart';
import '../datasources/review_remote_datasource.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource _dataSource;
  const ReviewRepositoryImpl(this._dataSource);

  @override
  Future<void> submitReview({
    required String jobId,
    required String clientId,
    required String providerId,
    required double score,
    String? comment,
    List<String> photoPaths = const [],
  }) =>
      _dataSource.submitReview(
        jobId: jobId,
        clientId: clientId,
        providerId: providerId,
        score: score,
        comment: comment,
        photoPaths: photoPaths,
      );

  @override
  Future<({double score, String? comment})?> getJobReview(String jobId) =>
      _dataSource.getJobReview(jobId);

  @override
  Future<List<ProviderReview>> getProviderReviews(
    String providerId, {
    int? limit,
  }) =>
      _dataSource.getProviderReviews(providerId, limit: limit);
}
