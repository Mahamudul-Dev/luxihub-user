import '../../../../core/domain/entities/service_provider_entity.dart';
import '../../../../core/domain/entities/user_entity.dart';

class ServiceProviderModel {
  static ServiceProviderEntity fromJson(Map<String, dynamic> json) {
    final rawSkills = json['skills'] as List? ?? [];
    final skills = rawSkills
        .map((s) => (s as Map<String, dynamic>)['name'] as String)
        .toList();

    final rawReviews = json['reviews'] as List? ?? [];
    final scores = rawReviews
        .map((r) => ((r as Map<String, dynamic>)['score'] as num).toDouble())
        .toList();
    final reviewCount = scores.length;
    final avgRating =
        reviewCount > 0 ? scores.reduce((a, b) => a + b) / reviewCount : 0.0;

    final user = UserEntity(
      id: json['id'] as String,
      firstName: json['name'] as String? ?? '',
      lastName: '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      address: json['service_area'] as String? ?? '',
      profileImageUrl: json['avatar_path'] as String? ?? '',
      bio: '',
      city: json['service_area'] as String? ?? '',
      country: '',
      tocAccepted: false,
    );

    return ServiceProviderEntity(
      user: user,
      category: skills.isNotEmpty ? skills.first : 'General',
      skills: skills,
      ratePerHour: (json['hourly_rate'] as num?)?.toDouble() ?? 0.0,
      currency: '£',
      yearsOfExperience: 0,
      isAvailable: json['is_online'] as bool? ?? false,
      rating: avgRating,
      reviewCount: reviewCount,
      completedJobs: 0,
    );
  }
}
