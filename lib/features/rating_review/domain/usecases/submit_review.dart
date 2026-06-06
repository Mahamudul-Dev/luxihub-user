import 'package:equatable/equatable.dart';

import '../repositories/review_repository.dart';

class SubmitReview {
  final ReviewRepository _repository;
  const SubmitReview(this._repository);

  Future<void> call(SubmitReviewParams params) => _repository.submitReview(
        jobId: params.jobId,
        clientId: params.clientId,
        providerId: params.providerId,
        score: params.score,
        comment: params.comment,
        photoPaths: params.photoPaths,
      );
}

class SubmitReviewParams extends Equatable {
  final String jobId;
  final String clientId;
  final String providerId;
  final double score;
  final String? comment;
  final List<String> photoPaths;

  const SubmitReviewParams({
    required this.jobId,
    required this.clientId,
    required this.providerId,
    required this.score,
    this.comment,
    this.photoPaths = const [],
  });

  @override
  List<Object?> get props =>
      [jobId, clientId, providerId, score, comment, photoPaths];
}
