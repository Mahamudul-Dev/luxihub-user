import '../entities/provider_review.dart';
import '../repositories/review_repository.dart';

class GetProviderReviews {
  final ReviewRepository _repository;
  const GetProviderReviews(this._repository);

  Future<List<ProviderReview>> call(String providerId, {int? limit}) =>
      _repository.getProviderReviews(providerId, limit: limit);
}
