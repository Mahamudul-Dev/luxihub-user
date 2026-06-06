import '../../../../core/domain/entities/profile.dart';
import '../../../../core/enum/user_type.dart';

class ProfileModel {
  final String id;
  final String name;
  final String? phone;
  final String? email;
  final String? dob;
  final String? contractType;
  final double? hourlyRate;
  final String? serviceArea;
  final double? serviceLat;
  final double? serviceLng;
  final int? serviceRadiusKm;
  final String? avatarPath;
  final bool isOnline;
  final bool isKycVerified;
  final List<String> skills;
  final UserType userType;

  const ProfileModel({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.dob,
    this.contractType,
    this.hourlyRate,
    this.serviceArea,
    this.serviceLat,
    this.serviceLng,
    this.serviceRadiusKm,
    this.avatarPath,
    this.isOnline = false,
    this.isKycVerified = false,
    this.skills = const [],
    this.userType = UserType.client,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final rawSkills = json['skills'] as List<dynamic>? ?? [];
    return ProfileModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      dob: json['dob'] as String?,
      contractType: json['contract_type'] as String?,
      hourlyRate: (json['hourly_rate'] as num?)?.toDouble(),
      serviceArea: json['service_area'] as String?,
      serviceLat: (json['service_lat'] as num?)?.toDouble(),
      serviceLng: (json['service_lng'] as num?)?.toDouble(),
      serviceRadiusKm: json['service_radius_km'] as int?,
      avatarPath: json['avatar_path'] as String?,
      isOnline: json['is_online'] as bool? ?? false,
      isKycVerified: json['is_kyc_verified'] as bool? ?? false,
      skills: rawSkills
          .map((s) => (s as Map<String, dynamic>)['name'] as String)
          .toList(),
      userType: UserTypeX.fromString(json['user_type'] as String?),
    );
  }

  Profile toEntity() => Profile(
        id: id,
        name: name,
        phone: phone,
        email: email,
        dob: dob,
        contractType: contractType,
        hourlyRate: hourlyRate,
        serviceArea: serviceArea,
        serviceLat: serviceLat,
        serviceLng: serviceLng,
        serviceRadiusKm: serviceRadiusKm,
        avatarPath: avatarPath,
        isOnline: isOnline,
        isKycVerified: isKycVerified,
        skills: skills,
        userType: userType,
      );

  Map<String, dynamic> toUpdateJson() => {
        'name': name,
        'phone': phone,
        'email': email,
        'dob': dob,
      };
}
