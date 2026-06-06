import 'package:equatable/equatable.dart';

import '../../enum/user_type.dart';

class Profile extends Equatable {
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

  const Profile({
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

  @override
  List<Object?> get props => [id, name, phone, email, userType];
}
