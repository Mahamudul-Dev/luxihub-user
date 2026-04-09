class ReviewEntity {
  final String id;
  final String reviewerName;
  final String reviewerAvatarUrl;
  final double rating;
  final String comment;
  final String date;

  const ReviewEntity({
    required this.id,
    required this.reviewerName,
    required this.reviewerAvatarUrl,
    required this.rating,
    required this.comment,
    required this.date,
  });
}
