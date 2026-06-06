import '../repositories/review_repository.dart';

class GetJobReview {
  final ReviewRepository _repository;
  const GetJobReview(this._repository);

  Future<({double score, String? comment})?> call(String jobId) =>
      _repository.getJobReview(jobId);
}
