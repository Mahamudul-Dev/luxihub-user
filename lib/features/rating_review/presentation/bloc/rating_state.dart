part of 'rating_bloc.dart';

enum RatingStatus { idle, submitting, submitted }

final class RatingState extends Equatable {
  const RatingState({
    this.photos = const [],
    this.score = 0.0,
    this.comment = '',
    this.status = RatingStatus.idle,
  });

  final List<XFile> photos;
  final double score;
  final String comment;
  final RatingStatus status;

  RatingState copyWith({
    List<XFile>? photos,
    double? score,
    String? comment,
    RatingStatus? status,
  }) {
    return RatingState(
      photos: photos ?? this.photos,
      score: score ?? this.score,
      comment: comment ?? this.comment,
      status: status ?? this.status,
    );
  }

  @override
  List<Object> get props => [photos, score, comment, status];
}
