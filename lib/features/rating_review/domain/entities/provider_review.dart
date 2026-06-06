class ProviderReview {
  final double score;
  final String? comment;
  final String? clientName;
  final String? clientAvatarPath;
  final DateTime createdAt;
  final List<String> photoUrls;

  const ProviderReview({
    required this.score,
    this.comment,
    this.clientName,
    this.clientAvatarPath,
    required this.createdAt,
    this.photoUrls = const [],
  });
}
