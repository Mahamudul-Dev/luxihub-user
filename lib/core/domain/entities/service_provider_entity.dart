import 'user_entity.dart';

class ServiceProviderEntity {
  // All identity info (name, email, phone, profileImageUrl, bio, etc.)
  // lives in [user] — no duplication.
  final UserEntity user;

  // ── Service ────────────────────────────────────────────────────────────────
  final String category;        // e.g. "Plumbing", "Painting", "Carpentry"
  final List<String> skills;    // e.g. ["Pipe fitting", "Leak repair"]
  final double ratePerHour;
  final String currency;        // e.g. "£"
  final int yearsOfExperience;
  final bool isAvailable;

  // ── Stats ──────────────────────────────────────────────────────────────────
  final double rating;          // 0.0 – 5.0
  final int reviewCount;
  final int completedJobs;

  const ServiceProviderEntity({
    required this.user,
    required this.category,
    required this.skills,
    required this.ratePerHour,
    required this.currency,
    required this.yearsOfExperience,
    required this.isAvailable,
    required this.rating,
    required this.reviewCount,
    required this.completedJobs,
  });

  // ── Convenience pass-throughs ──────────────────────────────────────────────
  String get id              => user.id;
  String get fullName        => user.fullName;
  String get profileImageUrl => user.profileImageUrl;
  String get city            => user.city;
  String get country         => user.country;

  /// Formatted rate string, e.g. "£20/hour".
  String get formattedRate  => '$currency${ratePerHour.toStringAsFixed(0)}/hour';

  /// Formatted rating label, e.g. "4.5 (200 reviews)".
  String get ratingLabel    => '${rating.toStringAsFixed(1)} ($reviewCount reviews)';
}
