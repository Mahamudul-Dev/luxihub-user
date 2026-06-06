part of 'rating_bloc.dart';

sealed class RatingEvent extends Equatable {
  const RatingEvent();

  @override
  List<Object> get props => [];
}

final class RatingPhotoAdded extends RatingEvent {
  const RatingPhotoAdded(this.photos);
  final List<XFile> photos;

  @override
  List<Object> get props => [photos];
}

final class RatingPhotoRemoved extends RatingEvent {
  const RatingPhotoRemoved(this.index);
  final int index;

  @override
  List<Object> get props => [index];
}

final class RatingScoreChanged extends RatingEvent {
  const RatingScoreChanged(this.score);
  final double score;

  @override
  List<Object> get props => [score];
}

final class RatingCommentChanged extends RatingEvent {
  const RatingCommentChanged(this.comment);
  final String comment;

  @override
  List<Object> get props => [comment];
}

final class RatingSubmitted extends RatingEvent {
  final String jobId;
  final String providerId;
  const RatingSubmitted({required this.jobId, required this.providerId});

  @override
  List<Object> get props => [jobId, providerId];
}
